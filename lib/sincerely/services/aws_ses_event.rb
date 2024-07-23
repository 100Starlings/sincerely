# frozen_string_literal: true

module Sincerely
  module Services
    class AwsSesEvent
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def event_type
        event['eventType'].downcase
      end

      def message_id
        event.dig('mail', 'messageId')
      end

      def recipient
        event.dig('mail', 'destination')[0]
      end

      def timestamp
        Time.parse(event.dig(event_type, 'timestamp') || event.dig('mail', 'timestamp')) # rubocop:disable Rails/TimeZone
      end
    end
  end
end
