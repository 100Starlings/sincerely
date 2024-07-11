# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'sincerely'

require 'database_cleaner/active_record'
require 'generator_spec'

require 'support/database_config'
require 'support/notification'
require 'support/notification_template'

include DatabaseConfig # rubocop:disable Style/MixinUsage

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/test.log")

  init_database

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example| # rubocop:disable RSpec/HookArgument
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
