# frozen_string_literal: true

module Sincerely
  class DashboardController < ApplicationController
    def index
      filtered_notifications = apply_time_filter(notification_model)

      @total_notifications = filtered_notifications.count
      @notifications_by_state = filtered_notifications.group(:delivery_state).count
      @recent_notifications = filtered_notifications.order(created_at: :desc).limit(10)

      # Delivery rates
      total_sent = filtered_notifications.where.not(delivery_state: %w[draft rejected]).count
      delivered = filtered_notifications.where(delivery_state: %w[delivered opened clicked]).count
      @delivery_rate = total_sent.positive? ? (delivered.to_f / total_sent * 100).round(1) : 0

      # Engagement rates
      delivered_count = filtered_notifications.where(delivery_state: %w[delivered opened clicked]).count
      engaged = filtered_notifications.where(delivery_state: %w[opened clicked]).count
      @open_rate = delivered_count.positive? ? (engaged.to_f / delivered_count * 100).round(1) : 0

      # Recent events
      @recent_delivery_events = apply_time_filter(Sincerely::DeliveryEvent).order(created_at: :desc).limit(5)
      @recent_engagement_events = apply_time_filter(Sincerely::EngagementEvent).order(created_at: :desc).limit(5)

      # Templates count
      @templates_count = Sincerely::Templates::NotificationTemplate.count

      # Current period for display
      @current_period = params[:period] || '24h'
    end
  end
end
