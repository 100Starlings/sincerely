# frozen_string_literal: true

module DatabaseConfig
  def init_database
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

    create_notifications
    create_templates
  end

  def truncate_database
    ActiveRecord::Base.connection.execute(
      <<-SQL.squish
        DELETE FROM notifications;
        DELETE FROM notification_templates;
      SQL
    )
  end

  private

  def create_notifications # rubocop:disable Metrics/MethodLength
    ActiveRecord::Schema.define do
      create_table :notifications do |t|
        t.string   :recipient
        t.string   :notification_type
        t.text     :delivery_options
        t.string   :delivery_system
        t.string   :delivery_state
        t.datetime :sent_at
        t.datetime :scheduled_at
        t.integer  :delivery_attempts
        t.string   :message_id
        t.string   :error_message

        t.timestamps
      end
    end
  end

  def create_templates
    ActiveRecord::Schema.define do
      create_table :notification_templates do |t|
        t.integer :template_id
        t.string  :name
        t.string  :description
        t.string  :html_content
        t.string  :text_content

        t.timestamps
      end
    end
  end
end
