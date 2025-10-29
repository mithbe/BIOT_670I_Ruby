class ApplicationJob < ActiveJob::Base
  # Retry the job if the database deadlocks
  # retry_on ActiveRecord::Deadlocked

  # Skip the job if the records it needs are missing
  # discard_on ActiveJob::DeserializationError
end
