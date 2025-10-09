class FileRecordsController < ApplicationController
  before_action :authenticate_user!

  # -----------------------------
  # STANDARD ACTIONS
  # -----------------------------

  def index
    @file_records = FileRecord.all
  end

  def show
    @file_record = FileRecord.find(params[:id])
  end

  def new
    # If this is coming from a batch upload (after bulk_prepare)
    if params[:batch_id]
      @batch = current_user.upload_batches.find_by(id: params[:batch_id])

      if @batch.present?
        @files = @batch.files
        render :bulk_preview and return
      else
        redirect_to new_file_record_path, alert: "Batch not found or expired."
      end
    else
      @file_record = FileRecord.new
    end
  end

  def create
    @file_record = FileRecord.new(file_record_params.merge(user: current_user))

    if @file_record.save
      redirect_to file_records_path, notice: "File uploaded successfully."
    else
      render :new
    end
  end

  # -----------------------------
  # BULK UPLOAD FLOW
  # -----------------------------

  # Step 1: Receive and prepare uploaded files (zip or single)
  def bulk_prepare
    uploaded_items = Array.wrap(params[:files]).reject(&:blank?)
    if uploaded_items.blank?
      redirect_to new_file_record_path, alert: "No files selected." and return
    end

    @batch = current_user.upload_batches.create!(status: "preparing")
    staged = []

    uploaded_items.each do |uploaded|
      next if uploaded.blank?
      filename = uploaded.original_filename.to_s.downcase

      if filename.end_with?(".zip") || uploaded.content_type == "application/zip"
        staged.concat extract_zip(uploaded, @batch.id)
      else
        staged << save_temp_file(uploaded, @batch.id)
      end
    end

    # normalize & ensure every element is a hash with expected keys
    normalized = staged.map do |e|
      if e.is_a?(String)
        {
          "path" => File.basename(e),
          "temp_path" => e,
          "ext" => File.extname(e),
          "type" => infer_type_by_ext(File.extname(e)),
          "size" => (File.size(e) rescue nil)
        }
      else
        {
          "path" => e["path"] || e[:path] || File.basename(e["temp_path"] || e[:temp_path] || ""),
          "temp_path" => e["temp_path"] || e[:temp_path] || e["path"],
          "ext" => e["ext"] || e[:ext] || File.extname(e["path"] || ""),
          "type" => e["type"] || e[:type] || infer_type_by_ext(e["ext"] || File.extname(e["path"] || "")),
          "size" => e["size"] || e[:size] || (File.size(e["temp_path"]) rescue nil)
        }
      end
    end

    @batch.update!(files: normalized, status: "prepared")
    Rails.logger.info("[bulk_prepare] batch=#{@batch.id} files=#{normalized.length}")
    redirect_to new_file_record_path(batch_id: @batch.id)
  rescue => e
    Rails.logger.error("[bulk_prepare] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    @batch&.destroy
    redirect_to new_file_record_path, alert: "Failed to process upload: #{e.message}"
  end

  # Step 2: Commit metadata and create FileRecord entries
  def bulk_commit
    batch = current_user.upload_batches.find(params[:batch_id])
    rows = params[:rows] || {}

    if rows.blank?
      redirect_to new_file_record_path, alert: "No files provided." and return
    end

    saved = 0
    failed = 0

    rows.each_value do |row|
      begin
        temp_path = row["temp_path"] || row[:temp_path]
        entry_path = row["path"] || row[:path] || File.basename(temp_path.to_s)
        # sanitize and prevent traversal
        entry_path = Pathname.new(entry_path).cleanpath.to_s
        if entry_path.start_with?("..")
          raise "Invalid entry path #{entry_path}"
        end

        dest_full = File.join("/mnt/Dandelionfiles", entry_path)
        FileUtils.mkdir_p(File.dirname(dest_full))

        if temp_path && File.exist?(temp_path)
          FileUtils.mv(temp_path, dest_full)
        else
          # try extract from archive if present in batch
          if batch.archive&.attached?
            extracted_ok = false
            batch.archive.open(tmpdir: Rails.root.join("tmp")) do |archive_path|
              require "zip"
              Zip::File.open(archive_path) do |zipfile|
                entry = zipfile.find_entry(entry_path) || zipfile.find_entry(File.basename(entry_path))
                if entry
                  entry.extract(dest_full) { true }
                  extracted_ok = true
                end
              end
            end
            raise "Could not find #{entry_path} in archive" unless extracted_ok
          else
            raise "Temp file missing for #{entry_path}"
          end
        end

        # build metadata
        metadata = {
          "type_of_study" => row["type_of_study"],
          "keyword_1" => row["keyword_1"],
          "keyword_2" => row["keyword_2"],
          "species" => row["species"],
          "ingested_at_est" => Time.use_zone("Eastern Time (US & Canada)") { Time.zone.now.iso8601 },
          "uploader_email" => current_user.email
        }.compact

        fr = current_user.file_records.create!(
          name: File.basename(entry_path),
          original_name: File.basename(entry_path),
          file_type: row["file_type"] || infer_type_by_ext(File.extname(entry_path)),
          mime_type: mime_from_ext(File.extname(entry_path)),
          size: row["size"],
          storage_path: dest_full,
          metadata: metadata,
          tags: [row["keyword_1"], row["keyword_2"]].compact
        )

        # optional: attach to ActiveStorage if you want
        # fr.file.attach(io: File.open(dest_full, "rb"), filename: File.basename(dest_full))

        saved += 1
      rescue => e
        Rails.logger.error("[bulk_commit] failed for #{row.inspect}: #{e.class}: #{e.message}")
        failed += 1
      end
    end

    batch.update!(status: "completed")
    redirect_to file_records_path, notice: "Batch upload complete. Saved: #{saved}, Failed: #{failed}"
  rescue => e
    Rails.logger.error("[bulk_commit] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    redirect_to new_file_record_path, alert: "Failed to commit batch: #{e.message}"
  end
  # -----------------------------
  # PRIVATE HELPERS
  # -----------------------------

  private

  # Extracts contents of a .zip file into a temporary directory
  def extract_zip(uploaded_zip, batch_id = nil)
    require "zip"
    extracted = []

    # ensure the uploaded zip is saved to disk first
    zip_info = save_temp_file(uploaded_zip, batch_id)
    zip_path = zip_info["temp_path"]

    # use a dedicated extraction folder for this batch
    extract_root = Rails.root.join("tmp", "uploads", "batch_#{batch_id || 'anon'}", "extracted")
    FileUtils.mkdir_p(extract_root)

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.name_is_directory?
        # dest preserves nested path inside the zip
        dest = File.join(extract_root, entry.name)
        FileUtils.mkdir_p(File.dirname(dest))
        entry.extract(dest) { true } # overwrite if exists
        extracted << {
          "path" => entry.name,       # relative path inside zip (display/final name)
          "temp_path" => dest,        # actual extracted file on disk
          "ext" => File.extname(entry.name),
          "type" => infer_type_by_ext(File.extname(entry.name)),
          "size" => (File.size(dest) rescue nil)
        }
      end
    end

    extracted
  end

  # Saves a single uploaded file to tmp/uploads
  def save_temp_file(uploaded, batch_id = nil)
    temp_dir = Rails.root.join("tmp", "uploads", "batch_#{batch_id || 'anon'}")
    FileUtils.mkdir_p(temp_dir)
    safe_name = sanitize_filename(uploaded.original_filename.to_s)
    temp_path = File.join(temp_dir, safe_name)
    File.open(temp_path, "wb") { |f| f.write(uploaded.read) }

    {
      "path" => safe_name,         # canonical relative path for single-file uploads
      "temp_path" => temp_path,
      "ext" => File.extname(safe_name),
      "type" => infer_type_by_ext(File.extname(safe_name)),
      "size" => (File.size(temp_path) rescue nil)
    }
  end

  def sanitize_filename(name)
    name.to_s.gsub("\\", "/").gsub(%r{^/}, "").gsub("..", "").strip
  end

  def file_record_params
    params.require(:file_record).permit(
      :name, :original_name, :file_type, :mime_type,
      :size, :description, :storage_path, :metadata, tags: []
    )
  end
end
private

def infer_type_by_ext(ext)
  ext = ext.to_s.downcase

  case ext
  when ".jpg", ".jpeg", ".png", ".gif", ".tif", ".tiff", ".bmp"
    "image"
  when ".csv"
    "csv"
  when ".fasta", ".fa"
    "fasta"
  when ".zip"
    "archive"
  when ".pdf"
    "document"
  when ".txt", ".log"
    "text"
  else
    "unknown"
  end
end