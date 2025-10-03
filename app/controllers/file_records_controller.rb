require "zip"

class FileRecordsController < ApplicationController
  before_action :authenticate_user!

  # existing actions (index, new, create, show) remain unchanged
  def index
    @file_records = FileRecord.order(created_at: :desc)
  end

  def new
    @file_record = FileRecord.new
  end

  def create
    @file_record = current_user.file_records.new(file_record_params)

    # wrap extra params into metadata if needed
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
  # BULK STEP: Accept ZIP, parse entries, persist UploadBatch, redirect to preview
  #
  def bulk_prepare
    uploaded = params[:zip_file] || params[:archive] || params[:file] # tolerate different keys
    unless uploaded.present?
      redirect_to new_file_record_path, alert: "Please select a ZIP file." and return
    end

    # create batch and attach the uploaded archive
    @batch = current_user.upload_batches.create!(status: "uploaded")
    @batch.archive.attach(uploaded)

    files = [] # array of hashes: { "path", "size", "ext", "type" }

    # Open the attached archive (use tempfile path provided by ActiveStorage)
    @batch.archive.open(tmpdir: Rails.root.join("tmp")) do |archive_path|
      Zip::File.open(archive_path) do |zip|
        zip.each do |entry|
          next if entry.name_is_directory?
          ext = File.extname(entry.name).downcase
          files << {
            "path" => entry.name,         # full path inside zip
            "size" => entry.size,
            "ext"  => ext,
            "type" => infer_type_by_ext(ext)
          }
        end
      end
    end

    @batch.update!(files: files, status: "prepared")
    redirect_to bulk_preview_file_records_path(batch_id: @batch.id)
  rescue => e
    Rails.logger.error("[bulk_prepare] #{e.class}: #{e.message}\n#{e.backtrace&.first(8)&.join("\n")}")
    @batch&.destroy
    redirect_to new_file_record_path, alert: "Failed to process ZIP: #{e.message}"
  end

  #
  # BULK PREVIEW: show metadata-editable table for the batch
  #
  def bulk_preview
    @batch = current_user.upload_batches.find_by(id: params[:batch_id])
    unless @batch
      redirect_to new_file_record_path, alert: "Batch not found." and return
    end

    @files = @batch.files || []
    # @files is an array like:
    # [{ "path" => "images/a.png", "size" => 1234, "ext" => ".png", "type" => "image" }, ...]
  end

  #
  # BULK COMMIT is assumed to already exist in your app (it will consume params[:rows] and do extraction)
  # If you need edits to bulk_commit later, we can update it; for now we keep it as before.
  #

  private

  def file_record_params
    params.require(:file_record).permit(
      :name, :original_name, :file_type, :mime_type, :size,
      :description, :storage_path, metadata: {}, tags: []
    )
  end

  # helpers (same as earlier)
  def infer_type_by_ext(ext)
    case ext
    when ".jpg", ".jpeg", ".png", ".tif", ".tiff", ".gif" then "image"
    when ".csv", ".tsv", ".xlsx"                         then "spreadsheet"
    when ".fasta", ".fa", ".fastq", ".fq", ".gb", ".gbk" then "genetic"
    when ".xml", ".pdf"                                  then "document"
    else "other"
    end
  end
end