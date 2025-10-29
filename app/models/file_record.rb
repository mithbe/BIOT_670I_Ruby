class FileRecord < ApplicationRecord
  # Automatically handle adding/removing records from Typesense search index
  include Typesenseable

  # Each file belongs to a user
  belongs_to :user

  # Make sure every file has a name and a storage location
  validates :name, presence: true
  validates :storage_path, presence: true

  # Define how this model looks to Typesense for searching
  def self.typesense_schema
    {
      "name" => "file_records",
      "fields" => [
        { "name" => "id", "type" => "string" },
        { "name" => "name", "type" => "string", "optional" => true, "sortable" => true },
        { "name" => "description", "type" => "string", "optional" => true, "sortable" => true },
        { "name" => "tags", "type" => "string[]", "optional" => true },
        { "name" => "metadata", "type" => "string", "optional" => true }
      ],
      "default_sorting_field" => "name"
    }
  end

  # Turn this record into a format Typesense can index
  def as_typesense_document
    tags_string = tags.is_a?(Array) ? tags.map(&:to_s) : []
    metadata_string = metadata.is_a?(Hash) ? metadata.to_s : ""

    {
      "id" => id.to_s,
      "name" => name.to_s,
      "description" => description.to_s,
      "tags" => tags_string,
      "metadata" => metadata_string
    }
  end

  # Search for file records using Typesense
  def self.typesense_search(query)
    search_parameters = {
      q: query,
      query_by: "name,description,tags,metadata"
    }

    results = Rails.application.config.typesense_client.collections["file_records"].documents.search(search_parameters)

    # Get the record IDs from the search results
    record_ids = results["hits"].map { |hit| hit["document"]["id"] }

    # Pull the full records from the database
    where(id: record_ids)
  end
end
