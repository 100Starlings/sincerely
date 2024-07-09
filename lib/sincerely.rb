# frozen_string_literal: true

require_relative 'generators/sincerely/install_generator'
require_relative 'generators/sincerely/migration_generator'
require_relative 'sincerely/version'

module Sincerely
  class Error < StandardError; end
end
