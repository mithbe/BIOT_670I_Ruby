# This file initializes the Typesense client, making it accessible throughout your Rails application.

# Load the Typesense gem
require "typesense"

# Configure the client connection details.
# We use environment variables for host, port, protocol, and API key so that these values
# can be easily changed for different environments (e.g., development vs. production).
client = Typesense::Client.new(
  api_key:         ENV.fetch("TYPESENSE_API_KEY", "xyz"),
  nodes: [ {
    host:     ENV.fetch("TYPESENSE_HOST", "localhost"),
    port:     ENV.fetch("TYPESENSE_PORT", 8108),
    protocol: ENV.fetch("TYPESENSE_PROTOCOL", "http")
  } ],
  connection_timeout_seconds: 2
)

# Make the client available globally. You can also use Rails.application.config.typesense_client
# if you prefer not to use a global variable.
Rails.application.config.typesense_client = client

# A helper method to make it easy to access the client from anywhere.
def client
  Rails.application.config.typesense_client
end
