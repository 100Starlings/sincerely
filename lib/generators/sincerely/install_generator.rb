# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Sincerely
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Generates a config file.'

      def copy_initializer
        template('sincerely.yml', 'config/sincerely.yml')
      end
    end
  end
end
