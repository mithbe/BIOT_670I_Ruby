require "active_support/core_ext/integer/time"
# Load Rails extensions for time calculations (like 1.year)

Rails.application.configure do
  # Settings here override config/application.rb for the production environment

  # Code is not reloaded between requests (improves performance)
  config.enable_reloading = false

  # Load all code on boot for better performance and memory savings
  config.eager_load = true

  # Do not show full error reports
  config.consider_all_requests_local = false

  # Enable fragment caching in views
  config.action_controller.perform_caching = true

  # Cache assets for one year since they are fingerprinted
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Serve assets from an asset server if configured
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files locally
  config.active_storage.service = :local

  # Assume SSL termination by a reverse proxy
  config.assume_ssl = true

  # Force HTTPS, use secure cookies and HSTS
  config.force_ssl = true

  # Skip SSL redirect for health check endpoint if needed
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log with request ID tags
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Set log level (default info; debug logs everything)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health check requests from cluttering logs
  config.silence_healthcheck_path = "/up"

  # Do not log deprecation warnings
  config.active_support.report_deprecations = false

  # Use a durable cache store instead of in-process memory
  config.cache_store = :solid_cache_store

  # Use a durable queue backend for Active Job
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore mailer delivery errors in production
  # config.action_mailer.raise_delivery_errors = false

  # Host used in mailer links
  config.action_mailer.default_url_options = { host: "example.com" }

  # Configure SMTP settings (optional)
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Fallback to default locale if translation is missing
  config.i18n.fallbacks = true

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false

  # Only include :id in Active Record inspections
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and restrict allowed hosts
  # config.hosts = ["example.com", /.*\.example\.com/]
  # Skip protection for health check endpoint if needed
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
