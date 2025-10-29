require_relative "boot"
require "rails/all"

# Load gems listed in Gemfile
Bundler.require(*Rails.groups)

module DandelionWarehouse
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.0
    config.load_defaults 8.0

    # Enable the asset pipeline
    config.assets.enabled = true

    # Autoload custom directories
    config.autoload_paths << Rails.root.join("lib/tasks")
    config.autoload_paths << Rails.root.join("lib/assets")
  end
end
