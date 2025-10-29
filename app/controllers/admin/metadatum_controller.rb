class Admin::MetadatumController < ApplicationController
  # Load a metadata record for show, edit, and update actions
  before_action :set_metadatum, only: [ :show, :edit, :update ]

  # List all metadata records
  def index
    @metadata = Metadatum.all
  end

  # Show a single metadata record
  def show; end

  # Render form to edit a metadata record
  def edit; end

  # Update a metadata record
  def update
    if @metadatum.update(metadatum_params)
      redirect_to admin_metadata_path(@metadatum), notice: "Metadata updated successfully."
    else
      render :edit
    end
  end

  private

  # Find metadata by ID
  def set_metadatum
    @metadatum = Metadatum.find(params[:id])
  end

  # Only allow listed fields to be updated
  def metadatum_params
    params.require(:metadatum).permit(
      :lab_or_author, :location, :research_type, :dandelion_strain,
      :stage_of_development, :description, :growing_info, :climate,
      :soil_type, :soil_texture, :ph, :rubber_method, :rubber_yield,
      :rubber_analysis, :file_type, :original_filename, :stored_filename,
      :file_size, :upload_timestamp, :uploader_ip, :version,
      :processing_status, :errors, :access_level, :metadata_json
    )
  end
end
