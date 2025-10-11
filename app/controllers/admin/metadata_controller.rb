class Admin::MetadataController < ApplicationController
  before_action :set_record, only: [:show, :edit, :update]

  # GET /admin/metadata
  def index
    @records = FileRecord.all
  end

  # GET /admin/metadata/:id
  def show
  end

  # GET /admin/metadata/:id/edit
  def edit
  end

  # PATCH/PUT /admin/metadata/:id
  def update
    if @record.update(metadata_params)
      redirect_to admin_metadata_path(@record), notice: "Metadata updated successfully."
    else
      render :edit
    end
  end

  private

  def set_record
    @record = FileRecord.find(params[:id])
  end

  def metadata_params
    params.require(:file_record).permit(:metadata_json)
  end
end

