# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Sincerely
  module Generators
    class MigrationGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::Migration

      source_root File.expand_path('../templates', __dir__)
      desc 'Installs Sincerely migration and model files.'

      def install # rubocop:disable Metrics/MethodLength
        if table_exist?
          migration_template('update_notifications.rb.erb', "db/migrate/update_#{plural_file_name}.rb",
                             migration_version:)
          add_mixins_to_existing_model
        else
          migration_template('create_notifications.rb.erb', "db/migrate/create_#{plural_file_name}.rb",
                             migration_version:)
          generate_model
        end

        migration_template('create_templates.rb.erb', "db/migrate/create_#{file_name}_templates.rb",
                           migration_version:)
        generate_template_model

        add_model_name_to_config
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      private

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def table_exist?
        ActiveRecord::Base.connection.table_exists?(plural_file_name.to_sym)
      end

      def add_mixins_to_existing_model
        model_path = "app/models/#{file_name}.rb"
        mixins_code = "\n  include Sincerely::Mixins::Model\n"

        insert_into_file model_path, after: "class #{class_name} < ApplicationRecord" do
          mixins_code
        end
      end

      def generate_model
        template('notification_model.rb.erb', "app/models/#{file_name}.rb")
      end

      def generate_template_model
        template('template_model.rb.erb', "app/models/#{file_name}_template.rb")
      end

      def add_model_name_to_config
        model_path = 'config/sincerely.yml'
        insert_into_file model_path, after: 'model_name: ' do
          class_name
        end
      end
    end
  end
end
