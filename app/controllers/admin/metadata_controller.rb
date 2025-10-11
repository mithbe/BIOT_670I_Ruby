class Admin::MetadataController < ApplicationController
  before_action :set_metadatum, only: [:show, :edit, :update]

  # GET /admin/metadata
  def index
    @metadata = Metadatum.all
  end

  # GET /admin/metadata/:id
  def show
  end

  # GET /admin/metadata/:id/edit
  def edit
  end

  # PATCH/PUT /admin/metadata/:id
  def update
    if @metadatum.update(metadatum_params)
      redirect_to admin_metadata_path(@metadatum), notice: "Metadata updated successfully."
    else
      render :edit
    end
  end

  private

  def set_metadatum
    @metadatum = Metadatum.find(params[:id])
  end

  def metadatum_params
    params.require(:metadatum).permit(
      :lab_or_author,
      :location,
      :research_type,
      :dandelion_strain,
      :stage_of_development,
      :description,
      :growing_info,
      :climate,
      :soil_type,
      :soil_texture,
      :ph,
      :rubber_method,
      :rubber_yield,
      :rubber_analysis,
      :file_type,
      :original_filename,
      :stored_filename,
      :file_size,
      :upload_timestamp,
      :uploader_ip,
      :version,
      :processing_status,
      :errors,
      :access_level,
      :metadata_json
    )
  end
end


