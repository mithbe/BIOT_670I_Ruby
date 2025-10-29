# This re-indexes all FileRecords into Typesense
# Useful for bulk-indexing or development

require_relative '../config/environment'
# Load Rails environment to access the database and Typesense client

typesense_client = Rails.application.config.typesense_client
# Use the pre-configured Typesense client

puts 'Indexing FileRecords into Typesense...'

# Check if the Typesense collection exists and create it if missing
begin
  typesense_client.collections['file_records'].retrieve
  puts 'Typesense collection for FileRecords already exists.'
rescue Typesense::ClientError => e
  if e.message.include?('Not Found')
    begin
      puts 'Typesense collection not found. Creating a new collection...'
      typesense_client.collections.create(FileRecord.typesense_schema)
      puts 'Collection created successfully.'
    rescue Typesense::ClientError => e
      puts "Error creating collection: #{e.message}"
    end
  else
    # raise any other Typesense errors
    raise e
  end
end

# Index all FileRecords from the database into Typesense
FileRecord.find_each do |record|
  begin
    document = record.as_typesense_document
    # create or update the record into Typesense
    typesense_client.collections['file_records'].documents.upsert(document)
  rescue StandardError => e
    # Log any records that failed to index
    Rails.logger.error("Failed to index record with ID #{record.id}: #{e.message}")
  end
end

puts 'Indexing complete!'
