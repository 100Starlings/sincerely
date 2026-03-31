# frozen_string_literal: true

module Sincerely
  class NotificationsController < ApplicationController
    def index
      @pagination = paginate(filtered_notifications)
      @notifications = @pagination[:records]
      @templates = available_templates
      @states = available_states
    end

    def show
      @notification = find_notification
      @template = @notification.template
      @timeline = build_event_timeline
    end

    private

    def filtered_notifications
      scope = base_notifications_scope
      scope = filter_by_status(scope)
      scope = filter_by_template(scope)
      scope = filter_by_recipient(scope)
      scope = filter_by_notification_type(scope)
      filter_by_date_range(scope)
    end

    def base_notifications_scope
      apply_notification_filter(apply_time_filter(notification_model)).order(created_at: :desc)
    end

    def filter_by_status(scope)
      return scope if params[:status].blank?

      scope.where(delivery_state: params[:status])
    end

    def filter_by_template(scope)
      return scope if params[:template_id].blank?

      scope.where(template_id: params[:template_id])
    end

    def filter_by_recipient(scope)
      return scope if params[:recipient].blank?

      scope.where('recipient LIKE ?', "%#{params[:recipient]}%")
    end

    def filter_by_notification_type(scope)
      return scope if params[:notification_type].blank?

      scope.where(notification_type: params[:notification_type])
    end

    def filter_by_date_range(scope)
      scope = scope.where(created_at: Date.parse(params[:date_from])..) if params[:date_from].present?
      scope = scope.where(created_at: ..Date.parse(params[:date_to]).end_of_day) if params[:date_to].present?
      scope
    end

    def find_notification
      apply_notification_filter(notification_model).find(params[:id])
    end

    def available_templates
      Sincerely::Templates::NotificationTemplate.all
    end

    def available_states
      notification_model.aasm.states.map(&:name)
    end

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
