ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_record/railtie'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

require 'sincerely'

class TestApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = 'test_secret_key_base_for_sincerely_specs'
  config.hosts << 'www.example.com'
  config.active_record.maintain_test_schema = false
  config.paths['config/database'] = [File.expand_path('config/database.yml', __dir__)]
  config.paths['config/routes.rb'] = []
end

Rails.application.initialize!

Rails.application.routes.draw do
  mount Sincerely::Engine => '/sincerely'
end

ActionController::Base.allow_forgery_protection = false

require 'rspec/rails'
require 'database_cleaner/active_record'

require 'support/database_config'
require 'support/notification'
require 'support/sincerely/delivery_event'
require 'support/sincerely/engagement_event'

include DatabaseConfig # rubocop:disable Style/MixinUsage

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpec::Rails::RequestExampleGroup, type: :request
  config.include Sincerely::Engine.routes.url_helpers

  ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/test.log")

  init_database

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
