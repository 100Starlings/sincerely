# frozen_string_literal: true

module Sincerely
  module Concerns
    module EventTimeline
      extend ActiveSupport::Concern

      private

      def build_event_timeline
        (delivery_events + engagement_events).sort_by { |e| e[:timestamp] }.reverse
      end

      def delivery_events
        events_for_model(Sincerely::DeliveryEvent)
      end

      def engagement_events
        events_for_model(Sincerely::EngagementEvent)
      end

      def events_for_model(model)
        return [] if @notification.message_id.nil?

        model.where(message_id: @notification.message_id).map do |event|
          {
            type: event.event_type,
            timestamp: event.timestamp || event.created_at,
            details: format_event_details(event.options)
          }
        end
      end

      def format_event_details(data)
        return nil if data.blank?

        data.is_a?(Hash) ? data.map { |k, v| "#{k}: #{v}" }.join(', ') : data.to_s
      end
    end
  end
end
