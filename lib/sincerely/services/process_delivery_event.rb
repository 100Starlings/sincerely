# frozen_string_literal: true

module Sincerely
  module Services
    class ProcessDeliveryEvent
      delegate :event_type, :message_id, :recipient, :timestamp, to: :event

      class << self
        def call(event:)
          new(event:).call
        end
      end

      def initialize(event:)
        @event = event
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      def call
        return if notification.blank?

        case event_type.to_sym
        when :bounce
          process_bounce_event
        when :complaint
          process_complaint_event
        when :delivery
          notification.set_delivered!
        when :send
          notification.set_accepted! if notification.may_set_accepted?
        when :reject
          notification.set_rejected!
          notification.update(error_message: event.rejection_reason)
        when :open
          process_engagement_event
        when :click
          notification.set_clicked!
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      attr_reader :event

      def process_bounce_event
        notification.set_bounced!
        Sincerely::BounceEvent.create(message_id:, delivery_system:, recipient:, timestamp:)
      end

      def process_complaint_event
        notification.set_complained!
        Sincerely::ComplaintEvent.create(message_id:, delivery_system:, recipient:, timestamp:)
      end

      def process_engagement_event
        notification.set_opened!
        Sincerely::EngagementEvent.create(message_id:, delivery_system:, recipient:, timestamp:)
      end

      def notification
        model = Sincerely.config.notification_model_name.constantize
        @notification ||= model.find_by(message_id:)
      end

      def delivery_system
        :aws_ses2
      end
    end
  end
end
