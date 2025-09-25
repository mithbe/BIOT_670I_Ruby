class FileRecord < ApplicationRecord
  # Include the Typesenseable concern to automatically handle
  # indexing and de-indexing records with Typesense.
  include Typesenseable

  # The file record belongs to a user.
  belongs_to :user

  # Validate that the file has a name and a storage path.
  validates :name, presence: true
  validates :storage_path, presence: true

  # This method defines the schema for Typesense.
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

  # This method formats the record into a document that Typesense can understand.
  def as_typesense_document
    # Convert tags and metadata JSON to a string so Typesense can index it.
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

  # We now have a clean way to perform searches on the model.
  def self.typesense_search(query)
    search_parameters = {
      q: query,
      query_by: "name,description,tags,metadata"
    }

    results = Rails.application.config.typesense_client.collections["file_records"].documents.search(search_parameters)

    # We get a list of record IDs from the search results
    record_ids = results["hits"].map { |hit| hit["document"]["id"] }

    # We can now use `where` to pull the full records from the database
    where(id: record_ids)
  end
end
