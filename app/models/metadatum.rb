class Metadatum < ApplicationRecord
  belongs_to :file_record
  belongs_to :user

  store_accessor :metadata_json, :nutrient_protocols, :fertilizers, :climate, :water_level, :soil_type, :soil_structure

  validates :lab, :type_of_research, :dandelion_strain, presence: true

  after_save :index_in_typesense

  private

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
