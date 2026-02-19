# frozen_string_literal: true

module Sincerely
  class NotificationsController < ApplicationController
    def index
      @notifications = apply_time_filter(notification_model).order(created_at: :desc)

      # Apply filters
      @notifications = @notifications.where(delivery_state: params[:status]) if params[:status].present?
      @notifications = @notifications.where(template_id: params[:template_id]) if params[:template_id].present?
      @notifications = @notifications.where('recipient LIKE ?', "%#{params[:recipient]}%") if params[:recipient].present?
      @notifications = @notifications.where(notification_type: params[:notification_type]) if params[:notification_type].present?

      if params[:date_from].present?
        @notifications = @notifications.where('created_at >= ?', Date.parse(params[:date_from]))
      end
      if params[:date_to].present?
        @notifications = @notifications.where('created_at <= ?', Date.parse(params[:date_to]).end_of_day)
      end

      @pagination = paginate(@notifications)
      @notifications = @pagination[:records]
      @templates = Sincerely::Templates::NotificationTemplate.all
      @states = notification_model.aasm.states.map(&:name)
    end

    def show
      @notification = notification_model.find(params[:id])
      @template = @notification.template
      @timeline = build_event_timeline(@notification)
    end

    private

    def build_event_timeline(notification)
      events = []

      Sincerely::DeliveryEvent.where(message_id: notification.message_id).find_each do |event|
        events << {
          type: event.event_type,
          timestamp: event.timestamp || event.created_at,
          details: format_event_details(event.options)
        }
      end

      Sincerely::EngagementEvent.where(message_id: notification.message_id).find_each do |event|
        events << {
          type: event.event_type,
          timestamp: event.timestamp || event.created_at,
          details: format_event_details(event.options)
        }
      end

      events.sort_by { |e| e[:timestamp] }.reverse
    end

    def format_event_details(data)
      return nil if data.blank?

      data.is_a?(Hash) ? data.map { |k, v| "#{k}: #{v}" }.join(', ') : data.to_s
    end
  end
end
