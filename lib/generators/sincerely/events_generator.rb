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

        generate_model
      end

      private

      def generate_migration
        migration_template('events/delivery_events_create.rb.erb',
                           'db/migrate/create_sincerely_delivery_events.rb',
                           migration_version:)
        migration_template('events/engagement_events_create.rb.erb',
                           'db/migrate/create_sincerely_engagement_events.rb',
                           migration_version:)
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def generate_model
        template('events/delivery_event_model.rb.erb', 'app/models/sincerely/delivery_event.rb')
        template('events/engagement_event_model.rb.erb', 'app/models/sincerely/engagement_event.rb')
      end
    end
  end
end
