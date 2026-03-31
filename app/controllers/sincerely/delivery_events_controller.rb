# frozen_string_literal: true

module Sincerely
  class DeliveryEventsController < ApplicationController
    def index
      @pagination = paginate(filtered_events)
      @events = @pagination[:records]
      @event_types = available_event_types
      @templates = available_templates
    end

    private

    def filtered_events
      scope = base_events_scope
      scope = filter_by_event_type(scope)
      scope = filter_by_recipient(scope)
      filter_by_notification_attributes(scope)
    end

    def base_events_scope
      apply_event_filter(apply_time_filter(Sincerely::DeliveryEvent)).order(created_at: :desc)
    end

    def filter_by_event_type(scope)
      return scope unless params[:event_type].present?

      scope.where(event_type: params[:event_type])
    end

    def filter_by_recipient(scope)
      return scope unless params[:recipient].present?

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

    def available_event_types
      Sincerely::DeliveryEvent.distinct.pluck(:event_type).compact
    end

    def available_templates
      Sincerely::Templates::NotificationTemplate.all
    end
  end
end
