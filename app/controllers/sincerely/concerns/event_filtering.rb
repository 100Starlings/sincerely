# frozen_string_literal: true

module Sincerely
  module Concerns
    module EventFiltering
      extend ActiveSupport::Concern

      private

      def filtered_events
        scope = apply_event_filter(apply_time_filter(event_model)).order(created_at: :desc)
        scope = filter_by_event_type(scope)
        scope = filter_by_recipient(scope)
        filter_by_notification_attributes(scope)
      end

      def filter_by_event_type(scope)
        return scope if params[:event_type].blank?

        scope.where(event_type: params[:event_type])
      end

      def filter_by_recipient(scope)
        return scope if params[:recipient].blank?

        scope.where('recipient LIKE ?', "%#{params[:recipient]}%")
      end

      def filter_by_notification_attributes(scope)
        return scope unless params[:template_id].present? || params[:notification_type].present?

        scope.where(message_id: filtered_message_ids)
      end

      def filtered_message_ids
        scope = notification_model.all
        scope = scope.where(template_id: params[:template_id]) if params[:template_id].present?
        scope = scope.where(notification_type: params[:notification_type]) if params[:notification_type].present?
        scope.pluck(:message_id).compact
      end

      def preload_notifications(events)
        message_ids = events.map(&:message_id).compact.uniq
        return {} if message_ids.empty?

        notification_model.where(message_id: message_ids).index_by(&:message_id)
      end

      def available_event_types
        event_model.distinct.pluck(:event_type).compact
      end

      def available_templates
        Sincerely::Templates::NotificationTemplate.all
      end
    end
  end
end
