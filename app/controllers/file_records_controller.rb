require "zip"

class FileRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    @file_records = FileRecord.order(created_at: :desc)
  end

  def new
    @file_record = FileRecord.new
    # If coming back from bulk_prepare, these instance vars let the page render the table
    if params[:batch_id].present?
      @batch = current_user.upload_batches.find_by(id: params[:batch_id])
      @files = @batch&.files || []
    end
  end

  def create
    @file_record = current_user.file_records.new(file_record_params)

    # Wrap arbitrary form fields into metadata JSON if a raw hash was sent:
    if params[:file_record].present?
      raw = params[:file_record].to_unsafe_h
      base_keys = file_record_params.keys.map(&:to_s)
      extra = raw.except(*base_keys, "controller", "action")
      @file_record.metadata = (@file_record.metadata || {}).merge(extra)
    end

    if @file_record.save
      redirect_to file_records_path, notice: "File uploaded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @file_record = FileRecord.find(params[:id])
  end

  #
  # BULK: Step 1 - accept ZIP, list files (don’t store files permanently yet)
  #
  def bulk_prepare
    unless params[:archive].present?
      redirect_to new_file_record_path, alert: "Please select a ZIP file." and return
    end

    # Create a temporary batch and attach the ZIP
    @batch = current_user.upload_batches.create!
    @batch.archive.attach(params[:archive])

    files = []
    @batch.archive.open(tmpdir: Rails.root.join("tmp")) do |path|
      Zip::File.open(path) do |zip|
        zip.entries.each do |entry|
          next if entry.name_is_directory?
          ext = File.extname(entry.name).downcase
          files << {
            "path" => entry.name,
            "size" => entry.size,
            "ext"  => ext,
            "type" => infer_type_by_ext(ext) # image/spreadsheet/genetic/other
          }
        end
      end
    end

    @batch.update!(files: files, status: "prepared")

    # Render the same 'new' page, but with the table visible
    redirect_to new_file_record_path(batch_id: @batch.id)
  end

  #
  # BULK: Step 2 - confirm rows, extract files, create FileRecord rows
  #
  def bulk_commit
    @batch = current_user.upload_batches.find(params[:batch_id])
    rows  = params.require(:rows) # array of hashes (one per file)

    ingested_at_est = Time.use_zone("Eastern Time (US & Canada)") { Time.zone.now }

    # We’ll extract the actual files to disk under storage/ingested/<batch_id>/...
    base_dir = Rails.root.join("storage", "ingested", @batch.id.to_s)
    FileUtils.mkdir_p(base_dir)

    created = []

    # Open the archive and extract only the selected rows by path
    @batch.archive.open(tmpdir: Rails.root.join("tmp")) do |archive_path|
      Zip::File.open(archive_path) do |zip|
        rows.each do |_, row|
          relative_path = row[:path] || row["path"]
          next if relative_path.blank?

          zip_entry = zip.find_entry(relative_path)
          next unless zip_entry

          dest_path = base_dir.join(relative_path)
          FileUtils.mkdir_p(dest_path.dirname)
          zip_entry.extract(dest_path.to_s) { true } # overwrite if exists

          # Build metadata
          metadata = {
            "type_of_study" => row[:type_of_study] || row["type_of_study"],
            "keyword_1"     => row[:keyword_1]     || row["keyword_1"],
            "keyword_2"     => row[:keyword_2]     || row["keyword_2"],
            "species"       => row[:species]       || row["species"],
            # uneditable, tracked
            "ingested_at_est" => ingested_at_est.iso8601,
            "uploader_email"  => current_user.email,
          }

          # Per-type placeholder columns (stored under metadata)
          # We keep keys present even if blank for consistency
          per_type = {
            "jpg_metadata"   => row[:jpg_metadata]   || row["jpg_metadata"],
            "png_metadata"   => row[:png_metadata]   || row["png_metadata"],
            "csv_metadata"   => row[:csv_metadata]   || row["csv_metadata"],
            "tsv_metadata"   => row[:tsv_metadata]   || row["tsv_metadata"],
            "xlsx_metadata"  => row[:xlsx_metadata]  || row["xlsx_metadata"],
            "fasta_metadata" => row[:fasta_metadata] || row["fasta_metadata"],
            "fastq_metadata" => row[:fastq_metadata] || row["fastq_metadata"],
            "genbank_metadata" => row[:genbank_metadata] || row["genbank_metadata"],
            "xml_metadata"   => row[:xml_metadata]   || row["xml_metadata"],
            "pdf_metadata"   => row[:pdf_metadata]   || row["pdf_metadata"],
            "other_metadata" => row[:other_metadata] || row["other_metadata"],
          }.compact

          # Normalize tags from the 2 keywords (simple start)
          tags = [row[:keyword_1], row[:keyword_2]].compact_blank

          fr = current_user.file_records.new(
            name:          File.basename(relative_path),
            original_name: File.basename(relative_path),
            file_type:     row[:file_type] || row["file_type"] || infer_type_by_ext(File.extname(relative_path)),
            mime_type:     mime_from_ext(File.extname(relative_path)),
            size:          File.size?(dest_path) || 0,
            description:   row[:description] || row["description"],
            tags:          tags,
            storage_path:  dest_path.relative_path_from(Rails.root).to_s,
            metadata:      metadata.merge(per_type)
          )

          fr.save!
          created << fr.id
        end
      end
    end

    @batch.committed!
    redirect_to file_records_path, notice: "Created #{created.size} records from ZIP."
  rescue => e
    Rails.logger.error("[bulk_commit] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    redirect_to new_file_record_path(batch_id: @batch.id), alert: "There was a problem committing the batch: #{e.message}"
  end

  private

  # BASIC helpers; expand later
  def infer_type_by_ext(ext)
    case ext
    when ".jpg", ".jpeg", ".png", ".tif", ".tiff", ".gif" then "image"
    when ".csv", ".tsv", ".xlsx"                         then "spreadsheet"
    when ".fasta", ".fa", ".fastq", ".fq", ".gb", ".gbk" then "genetic"
    when ".xml", ".pdf"                                  then "document"
    else "other"
    end
  end

  def mime_from_ext(ext)
    case ext.downcase
    when ".jpg", ".jpeg" then "image/jpeg"
    when ".png"          then "image/png"
    when ".tif", ".tiff" then "image/tiff"
    when ".gif"          then "image/gif"
    when ".csv"          then "text/csv"
    when ".tsv"          then "text/tab-separated-values"
    when ".xlsx"         then "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    when ".fasta", ".fa" then "chemical/seq-na-fasta"
    when ".fastq", ".fq" then "chemical/seq-na-fastq"
    when ".gb", ".gbk"   then "chemical/seq-na-genbank"
    when ".xml"          then "application/xml"
    when ".pdf"          then "application/pdf"
    else "application/octet-stream"
    end
  end

  def file_record_params
    params.require(:file_record).permit(
      :name, :original_name, :file_type, :mime_type, :size, :description,
      :storage_path, metadata: {}, tags: []
    )
  end
end