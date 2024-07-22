# frozen_string_literal: true

module Sincerely
  module Services
    class SesEvent
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def event_type
        event['eventType'].downcase
      end

      def message_id
        event['mail']['messageId']
      end

      def recipient
        event['mail']['destination'][0]
      end

      def timestamp
        Time.parse(event[event_type]['timestamp'] || event['mail']['timestamp']) # rubocop:disable Rails/TimeZone
      end
    end
  end
end
