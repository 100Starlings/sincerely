# frozen_string_literal: true

module Sincerely
  class DashboardController < ApplicationController
    include Concerns::Periods
    include Concerns::DeliveryMetrics
    include Concerns::NotificationTimeline

    def index
      @total_notifications = filtered_notifications.count
      @notifications_by_state = filtered_notifications.group(:delivery_state).count
      @recent_notifications = filtered_notifications.order(created_at: :desc).limit(10)
      @delivery_rate = calculate_delivery_rate
      @open_rate = calculate_open_rate
      @bounce_rate = calculate_bounce_rate
      @recent_delivery_events = recent_delivery_events
      @recent_engagement_events = recent_engagement_events
      @notifications_by_message_id = preload_notifications_for_events
      @current_period = current_period
      @notifications_timeline = build_timeline_data(filtered_notifications)
    end

    private

    def filtered_notifications
      @filtered_notifications ||= apply_notification_filter(apply_time_filter(notification_model))
    end

    def user_message_ids_subquery
      filtered_notifications.where.not(message_id: nil).select(:message_id)
    end

    def recent_delivery_events
      apply_time_filter(Sincerely::DeliveryEvent)
        .where(message_id: user_message_ids_subquery)
        .order(created_at: :desc)
        .limit(5)
    end

    def recent_engagement_events
      apply_time_filter(Sincerely::EngagementEvent)
        .where(message_id: user_message_ids_subquery)
        .order(created_at: :desc)
        .limit(5)
    end

    def preload_notifications_for_events
      message_ids = (@recent_delivery_events + @recent_engagement_events).map(&:message_id).compact.uniq
      return {} if message_ids.empty?

      notification_model.where(message_id: message_ids).index_by(&:message_id)
    end
  end
end
