# This script is used to manually re-index all FileRecords into Typesense.
# It is useful for bulk-indexing existing records or for development.

# This is crucial for running the script within the full Rails environment.
# The Typesense client is initialized in an initializer file that gets loaded here.
require_relative '../config/environment'

# We use the client that has been configured in the initializer.
typesense_client = Rails.application.config.typesense_client

puts 'Indexing FileRecords into Typesense...'

# Check for the existence of the Typesense collection.
# If it doesn't exist, we create it.
begin
  typesense_client.collections['file_records'].retrieve
  puts 'Typesense collection for FileRecords already exists.'
rescue Typesense::ClientError => e
  # If the collection is not found, we create it.
  if e.message.include?('Not Found')
    begin
      puts 'Typesense collection not found. Creating a new collection...'
      typesense_client.collections.create(FileRecord.typesense_schema)
      puts 'Collection created successfully.'
    rescue Typesense::ClientError => e
      puts "Error creating collection: #{e.message}"
    end
  else
    # For any other Typesense error, we'll re-raise it.
    raise e
  end
end

# Now we iterate through all FileRecords in the database and index each one.
FileRecord.find_each do |record|
  begin
    # The `as_typesense_document` method formats the record for Typesense.
    document = record.as_typesense_document
    # We use `upsert` to either create a new document or update an existing one.
    typesense_client.collections['file_records'].documents.upsert(document)
  rescue StandardError => e
    # We log any errors to the console so we know which records failed.
    Rails.logger.error("Failed to index record with ID #{record.id}: #{e.message}")
  end
end

puts 'Indexing complete!'
