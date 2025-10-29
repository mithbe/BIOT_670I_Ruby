class FileRecordsController < ApplicationController
  # Require users to be logged in
  before_action :authenticate_user!

  # -----------------------------
  # STANDARD ACTIONS
  # -----------------------------

  # List all file records, optionally filtered by search term
  def index
    if params[:search].present?
      @file_records = FileRecord.typesense_search(params[:search])
    else
      @file_records = FileRecord.all
    end
  end

  # Show details for a single file record
  def show
    @file_record = FileRecord.find(params[:id])
  end

  # Display form for new file upload
  # Handles batch preview if coming from a bulk upload
  def new
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

  # Save a new file record
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

  # Step 1: Receive and stage uploaded files (single or zip)
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

    # Normalize each staged file to expected hash format
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

    # Update batch with staged files and mark as prepared
    @batch.update!(files: normalized, status: "prepared")
    Rails.logger.info("[bulk_prepare] batch=#{@batch.id} files=#{normalized.length}")
    redirect_to new_file_record_path(batch_id: @batch.id)
  rescue => e
    Rails.logger.error("[bulk_prepare] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    @batch&.destroy
    redirect_to new_file_record_path, alert: "Failed to process upload: #{e.message}"
  end

  # Step 2: Commit staged files to FileRecord entries and save metadata
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
        entry_path = Pathname.new(entry_path).cleanpath.to_s
        raise "Invalid entry path #{entry_path}" if entry_path.start_with?("..")

        dest_full = File.join("/mnt/Dandelionfiles", entry_path)
        FileUtils.mkdir_p(File.dirname(dest_full))

        # Move file from temp path or extract from archive
        if temp_path && File.exist?(temp_path)
          FileUtils.mv(temp_path, dest_full)
        else
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

        # Build metadata and create FileRecord
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
          tags: [ row["keyword_1"], row["keyword_2"] ].compact
        )

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

  # Extracts files from a zip archive into a temporary folder
  def extract_zip(uploaded_zip, batch_id = nil)
    require "zip"
    extracted = []

    zip_info = save_temp_file(uploaded_zip, batch_id)
    zip_path = zip_info["temp_path"]

    extract_root = Rails.root.join("tmp", "uploads", "batch_#{batch_id || 'anon'}", "extracted")
    FileUtils.mkdir_p(extract_root)

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.name_is_directory?
        dest = File.join(extract_root, entry.name)
        FileUtils.mkdir_p(File.dirname(dest))
        entry.extract(dest) { true } # overwrite if exists
        extracted << {
          "path" => entry.name,
          "temp_path" => dest,
          "ext" => File.extname(entry.name),
          "type" => infer_type_by_ext(File.extname(entry.name)),
          "size" => (File.size(dest) rescue nil)
        }
      end
    end

    extracted
  end

  # Save an uploaded file temporarily before processing
  def save_temp_file(uploaded, batch_id = nil)
    temp_dir = Rails.root.join("tmp", "uploads", "batch_#{batch_id || 'anon'}")
    FileUtils.mkdir_p(temp_dir)
    safe_name = sanitize_filename(uploaded.original_filename.to_s)
    temp_path = File.join(temp_dir, safe_name)
    File.open(temp_path, "wb") { |f| f.write(uploaded.read) }

    {
      "path" => safe_name,
      "temp_path" => temp_path,
      "ext" => File.extname(safe_name),
      "type" => infer_type_by_ext(File.extname(safe_name)),
      "size" => (File.size(temp_path) rescue nil)
    }
  end

  # Remove unsafe characters from filenames
  def sanitize_filename(name)
    name.to_s.gsub("\\", "/").gsub(%r{^/}, "").gsub("..", "").strip
  end

  # Strong parameters for single-file uploads
  def file_record_params
    params.require(:file_record).permit(
      :name, :original_name, :file_type, :mime_type,
      :size, :description, :storage_path, :metadata, tags: []
    )
  end
end

# Infer file type based on extension
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
