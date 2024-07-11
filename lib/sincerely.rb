# frozen_string_literal: true

require_relative 'config/application_config'
require_relative 'config/sincerely_config'
require_relative 'generators/sincerely/install_generator'
require_relative 'generators/sincerely/migration_generator'
require_relative 'sincerely/mixins/model'
require_relative 'sincerely/version'

module Sincerely
  class Error < StandardError; end
end
