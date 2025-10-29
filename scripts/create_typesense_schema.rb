# This script creates a Typesense collection (a.k.a. schema) for your file records.
# It defines the fields that will be indexed and searched.

# This ensures the script is using the Rails environment so it can access
# the Typesense client you configured.
require_relative '../config/environment'
# This line is needed to access the Typesense error classes.
require 'typesense'

puts "Creating Typesense collection for FileRecords..."

# The schema defines the name of the collection and the fields it will contain.
# We make sure the `id` field is present, as it is required by Typesense.
file_records_schema = {
  'name'      => 'file_records',
  'fields'    => [
    { 'name' => 'id',          'type' => 'string' },
    { 'name' => 'name',        'type' => 'string' },
    { 'name' => 'description', 'type' => 'string', 'optional' => true },
    { "name" => 'tags',        'type' => 'string[]', 'optional' => true },
    { "name" => 'metadata',    'type' => 'string', 'optional' => true },
    { 'name' => 'file_type',   'type' => 'string', 'optional' => true },
    { 'name' => 'user_id',     'type' => 'string', 'optional' => true }
  ]
}

# The rescue block is crucial to prevent an error if the collection already exists.
begin
  # This line creates the collection on your running Typesense server.
  client.collections.create(file_records_schema)
  puts "Collection 'file_records' created successfully."
rescue Typesense::Error => e
  # If the collection already exists, we just print a message and continue.
  if e.to_s.include?('already exists')
    puts "Collection 'file_records' already exists and cannot be modified."
    puts "To apply new schema, existing collection must be deleted (ALL INDEXED DATA WILL BE LOST)."
    print "Do you want to delete and re-write 'file_records'? [yes/no]: "
    
    user_input = gets.chomp.downcase

    if user_input == 'yes'
      puts "Attempting to delete old collection..."

      begin
        # Delete the old collection
        client.collections['file_records'].delete
        puts "Old collection deleted successfully."

        # Attempt 2: Create the collection again with the new schema
        client.collections.create(file_records_schema)
        puts "Collection 'file_records' re-created successfully."

      rescue => delete_e
        puts "ERROR: Failed to delete or re-create the collection: #{delete_e.message}"
      end

    else
      puts "Skipping schema update. The existing collection remains unchanged."
    end
    puts "---"
  else
    # Re-raise any other unexpected Typesense error (e.g., connection issue)
    puts "An unexpected Typesense error occurred: #{e.message}"
    raise
  end
end
