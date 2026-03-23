# frozen_string_literal: true

module Sincerely
  class DeliveryEventsController < ApplicationController
    def index
      @events = apply_time_filter(Sincerely::DeliveryEvent).order(created_at: :desc)
      @events = apply_event_filter(@events)

      @events = @events.where(event_type: params[:event_type]) if params[:event_type].present?
      @events = @events.where('recipient LIKE ?', "%#{params[:recipient]}%") if params[:recipient].present?

      if params[:template_id].present? || params[:notification_type].present?
        notification_scope = notification_model.all
        if params[:template_id].present?
          notification_scope = notification_scope.where(template_id: params[:template_id])
        end
        if params[:notification_type].present?
          notification_scope = notification_scope.where(notification_type: params[:notification_type])
        end
        message_ids = notification_scope.pluck(:message_id).compact
        @events = @events.where(message_id: message_ids)
      end

      @pagination = paginate(@events)
      @events = @pagination[:records]

      @event_types = Sincerely::DeliveryEvent.distinct.pluck(:event_type).compact
      @templates = Sincerely::Templates::NotificationTemplate.all
    end
  end
end
