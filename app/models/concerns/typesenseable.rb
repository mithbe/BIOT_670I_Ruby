module Typesenseable
  extend ActiveSupport::Concern

  included do
    # This method defines the schema for Typesense. It tells the search
    # server what fields exist and how to treat them.
    # The method is defined as a class method so it can be called by a
    # script or other parts of the application.
    def self.typesense_schema
      {
        'name' => 'file_records',
        'fields' => [
          { 'name' => 'id', 'type' => 'string' },
          # We've added `sortable: true` to the fields we might want to sort by.
          { 'name' => 'name', 'type' => 'string', 'optional' => true, 'sortable' => true },
          { 'name' => 'original_name', 'type' => 'string', 'optional' => true, 'sortable' => true },
          { 'name' => 'description', 'type' => 'string', 'optional' => true, 'sortable' => true },
          { 'name' => 'tags', 'type' => 'string[]', 'optional' => true },
          { 'name' => 'metadata', 'type' => 'string', 'optional' => true }
        ],
        'default_sorting_field' => 'name'
      }
    end

    # This method is called after a record is saved to the database.
    # It ensures the record is also indexed in Typesense.
    after_save do
      begin
        document = as_typesense_document
        TYPESENSE_CLIENT.collections['file_records'].documents.upsert(document)
      rescue Typesense::Error => e
        Rails.logger.error("Typesense indexing error: #{e.message}")
      end
    end

    # This method is called after a record is deleted from the database.
    # It ensures the record is also deleted from Typesense.
    after_destroy do
      begin
        TYPESENSE_CLIENT.collections['file_records'].documents[id].delete
      rescue Typesense::Error => e
        Rails.logger.error("Typesense deletion error: #{e.message}")
      end
    end

    # This method formats the record into a document that Typesense can understand.
    def as_typesense_document
      # Convert tags and metadata JSON to a string so Typesense can index it.
      tags_string = tags.is_a?(Array) ? tags.map(&:to_s) : []
      metadata_string = metadata.is_a?(Hash) ? metadata.to_s : ''

      {
        'id' => id.to_s,
        'name' => name.to_s,
        'original_name' => original_name.to_s,
        'description' => description.to_s,
        'tags' => tags_string,
        'metadata' => metadata_string
      }
    end
  end
end