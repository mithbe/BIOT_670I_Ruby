require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module DandelionWarehouse
  class Application < Rails::Application
    config.load_defaults 8.0
    config.assets.enabled = true
    config.autoload_paths << Rails.root.join("lib/tasks")
    config.autoload_paths << Rails.root.join("lib/assets")
  end
end
