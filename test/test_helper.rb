ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Enable parallel testing
    parallelize(workers: :number_of_processors, with: :threads)

    # Load all fixtures
    fixtures :all
  end
end
