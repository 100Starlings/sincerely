# frozen_string_literal: true

module Sincerely
  module Services
    class ProcessDeliveryEvent
      delegate :event_type, :message_id, :recipient, :timestamp, :options, :delivery_system,
               to: :event

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
          notification.set_bounced!
          create_event
        when :complaint
          notification.set_complained!
          create_event
        when :delivery
          notification.set_delivered!
          create_event
        when :send
          notification.set_accepted! if notification.may_set_accepted?
        when :reject
          notification.set_rejected!
          notification.update(error_message: event.rejection_reason)
        when :open
          notification.set_opened!
          create_event
        when :click
          notification.set_clicked!
          create_event
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      attr_reader :event

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def create_event
        case event_type.to_sym
        when :bounce, :delivery
          Sincerely::DeliveryEvent.create(
            message_id:, delivery_system:, event_type:, recipient:, timestamp:, options:,
            delivery_event_type: event.delivery_event_type, delivery_event_subtype: event.delivery_event_subtype
          )
        else
          Sincerely::EngagementEvent.create(
            message_id:, delivery_system:, event_type:, recipient:, timestamp:, options:,
            ip_address: event.ip_address, user_agent: event.user_agent, link: event.link,
            feedback_type: event.feedback_type
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def notification
        model = Sincerely.config.notification_model_name.constantize
        @notification ||= model.find_by(message_id:)
      end
    end
  end
end
