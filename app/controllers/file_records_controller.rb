class FileRecordsController < ApplicationController
  def index
    if params[:search].present?
      @file_records = FileRecord.typesense_search(params[:search])
    else
      @file_records = FileRecord.all
    end
  end

  def new
    @file_record = FileRecord.new
  end

  def create
    @file_record = FileRecord.new(file_record_params)
    if @file_record.save
      redirect_to file_records_path, notice: "File uploaded successfully."
    else
      render :new
    end
  end

  def show
    @file_record = FileRecord.find(params[:id])
  end

  private

  def file_record_params
    params.require(:file_record).permit(:name, :original_name, :file_type, :mime_type, :size, :description, :storage_path, :metadata, tags: [])
  end
end