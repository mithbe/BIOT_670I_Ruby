# The test database is temporary and recreated between test runs.

Rails.application.configure do
  # Settings here override config/application.rb for the test environment

  # Code reloading is not needed while running tests
  config.enable_reloading = false

  # Eager load all code only in CI to check for load issues
  config.eager_load = ENV["CI"].present?

  # Configure public file server with caching for performance
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports
  config.consider_all_requests_local = true

  # Use a null cache store to avoid caching in tests
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions
  config.action_dispatch.show_exceptions = :rescuable

  # Disable CSRF protection in tests
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files locally in a temporary directory
  config.active_storage.service = :test

  # Don't send real emails; store them in ActionMailer::Base.deliveries
  config.action_mailer.delivery_method = :test

  # Host used in mailer links
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation warnings to stderr
  config.active_support.deprecation = :stderr

  # Raise error for missing translations (commented out)
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered views with filenames (commented out)
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error if before_action references a missing method
  config.action_controller.raise_on_missing_callback_actions = true
end
