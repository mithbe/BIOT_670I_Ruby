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
    puts "Collection 'file_records' already exists. Skipping creation."
  else
    raise
  end
end
