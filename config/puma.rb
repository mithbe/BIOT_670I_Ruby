# Puma web server configuration for Rails

# Minimum and maximum threads per worker
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Port Puma listens on
port ENV.fetch("PORT", 3000)

# Allow restarting Puma via `bin/rails restart`
plugin :tmp_restart

# Run Solid Queue inside Puma if configured
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Optional PID file
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
