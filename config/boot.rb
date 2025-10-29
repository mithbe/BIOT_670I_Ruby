# Ensure the correct Gemfile is used
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Set up gems from the Gemfile
require "bundler/setup"

# Speed up Rails boot time using caching
require "bootsnap/setup"
