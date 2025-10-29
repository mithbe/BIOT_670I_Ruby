# restart server when you modify this file
# frozen_string_literal: true

# Devise configuration
Devise.setup do |config|
  # Email sender for Devise mailers
  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"

  # Load and configure Active Record ORM
  require "devise/orm/active_record"

  # Authentication keys
  config.case_insensitive_keys = [ :email ]      # Downcase email before authentication
  config.strip_whitespace_keys = [ :email ]      # Remove spaces from email

  # Skip storing session for HTTP authentication
  config.skip_session_storage = [ :http_auth ]

  # Password hashing cost (faster in tests)
  config.stretches = Rails.env.test? ? 1 : 12

  # Require email reconfirmation on change
  config.reconfirmable = true

  # Expire all "remember me" tokens on sign out
  config.expire_all_remember_me_on_sign_out = true

  # Password length requirements
  config.password_length = 6..128

  # Simple email format validation
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Password reset period
  config.reset_password_within = 6.hours

  # Default HTTP method for sign out
  config.sign_out_via = :delete

  # Hotwire/Turbo status codes
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
