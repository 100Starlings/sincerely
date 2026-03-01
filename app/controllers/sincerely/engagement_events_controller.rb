# frozen_string_literal: true

module Sincerely
  class EngagementEventsController < ApplicationController
    def index
      @events = apply_time_filter(Sincerely::EngagementEvent).order(created_at: :desc)

      @events = @events.where(event_type: params[:event_type]) if params[:event_type].present?
      @events = @events.where('recipient LIKE ?', "%#{params[:recipient]}%") if params[:recipient].present?

      # Filter by notification properties via message_id
      if params[:template_id].present? || params[:notification_type].present?
        notification_scope = notification_model.all
        notification_scope = notification_scope.where(template_id: params[:template_id]) if params[:template_id].present?
        notification_scope = notification_scope.where(notification_type: params[:notification_type]) if params[:notification_type].present?
        message_ids = notification_scope.pluck(:message_id).compact
        @events = @events.where(message_id: message_ids)
      end

      @pagination = paginate(@events)
      @events = @pagination[:records]

      @event_types = Sincerely::EngagementEvent.distinct.pluck(:event_type).compact
      @templates = Sincerely::Templates::NotificationTemplate.all
    end
  end
end
