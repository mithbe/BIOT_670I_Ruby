class Metadatum < ApplicationRecord
  # Each metadata entry belongs to a specific file and user
  belongs_to :file_record
  belongs_to :user

  # Make it easy to read/write these keys from the JSON column
  store_accessor :metadata_json, :nutrient_protocols, :fertilizers, :climate, :water_level, :soil_type, :soil_structure

  # Make sure some important fields are always present
  validates :lab, :type_of_research, :dandelion_strain, presence: true

  # Automatically update the Typesense search index whenever this record changes
  after_save :index_in_typesense

  private

  # Push this record into Typesense for searching
  def index_in_typesense
    Typesense.client.collections["metadata"].documents.upsert(
      id: id.to_s,
      lab: lab,
      location: location,
      type_of_research: type_of_research,
      dandelion_strain: dandelion_strain,
      development_stage: development_stage,
      description: description
    )
  end
end
