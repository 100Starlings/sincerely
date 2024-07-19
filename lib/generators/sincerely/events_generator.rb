# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Sincerely
  module Generators
    class EventsGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      source_root File.expand_path('../templates', __dir__)
      desc 'Create event models and migrations'

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_migration_and_models
        generate_migration

        generate_event_model(:delivery_event)
        generate_event_model(:bounce_event)
        generate_event_model(:complaint_event)
        generate_event_model(:engagement_event)
      end

      private

      def generate_migration
        migration_template('events/delivery_events_create.rb.erb',
                           'db/migrate/create_sincerely_delivery_events.rb',
                           migration_version:)
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def generate_event_model(model_name)
        template("events/#{model_name}_model.rb.erb", "app/models/sincerely/#{model_name}.rb")
      end
    end
  end
end
