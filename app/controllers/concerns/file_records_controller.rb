class FileRecordsController < ApplicationController
  # List all file records
  def index
    @file_records = FileRecord.all
  end

  # Show the form for uploading a new file
  def new
    @file_record = FileRecord.new
  end

  # Create a new file record and save it
  def create
    @file_record = FileRecord.new(file_record_params)
    if @file_record.save
      redirect_to file_records_path, notice: "File uploaded successfully."
    else
      render :new
    end
  end

  # Display a single file record
  def show
    @file_record = FileRecord.find(params[:id])
  end

  private

  # Only allow the listed fields to be submitted for a file record
  def file_record_params
    params.require(:file_record).permit(
      :name, :original_name, :file_type, :mime_type, :size,
      :description, :storage_path, :metadata, tags: []
    )
  end
end
