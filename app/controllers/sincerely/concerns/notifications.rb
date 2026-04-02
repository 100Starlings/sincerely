# frozen_string_literal: true

module Sincerely
  module Concerns
    module Notifications
      extend ActiveSupport::Concern

      included do
        helper_method :notification_model
      end

      private

      def notification_model
        @notification_model ||= Sincerely.notification_model
      end

      def apply_notification_filter(scope)
        return scope unless notification_filter_callable?

        conditions = notification_filter_conditions
        conditions.blank? ? scope : scope.where(conditions)
      end

      def apply_event_filter(scope)
        return scope unless notification_filter_callable?

        conditions = notification_filter_conditions
        return scope if conditions.blank?

        scope.where(message_id: filtered_message_ids_for_events(conditions))
      end

      def notification_filter_callable?
        Sincerely.config.filter_notifications_by.respond_to?(:call)
      end

      def notification_filter_conditions
        instance_exec(&Sincerely.config.filter_notifications_by)
      end

      def filtered_message_ids_for_events(conditions)
        notification_model.where(conditions).where.not(message_id: nil).pluck(:message_id)
      end
    end
  end
end
