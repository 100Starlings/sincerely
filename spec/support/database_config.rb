# frozen_string_literal: true

module DatabaseConfig
  def init_database # rubocop:disable Metrics/MethodLength
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

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

  def truncate_database
    ActiveRecord::Base.connection.execute(
      <<-SQL.squish
        DELETE FROM notifications;
      SQL
    )
  end
end
