require "bundler/setup"
require 'rails'
require 'active_record'
require "paper_trail/active_record"
require 'paper_trail/frameworks/active_record'
require "timecop"
require "byebug"
require_relative 'support/connection'
require_relative 'support/models'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
