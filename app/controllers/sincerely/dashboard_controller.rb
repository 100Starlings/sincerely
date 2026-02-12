# frozen_string_literal: true

module Sincerely
  class DashboardController < ApplicationController
    def index
      @total_notifications = notification_model.count
      @notifications_by_state = notification_model.group(:delivery_state).count
      @recent_notifications = notification_model.order(created_at: :desc).limit(10)

      # Delivery rates
      total_sent = notification_model.where.not(delivery_state: %w[draft rejected]).count
      delivered = notification_model.where(delivery_state: %w[delivered opened clicked]).count
      @delivery_rate = total_sent.positive? ? (delivered.to_f / total_sent * 100).round(1) : 0

      # Engagement rates
      delivered_count = notification_model.where(delivery_state: %w[delivered opened clicked]).count
      engaged = notification_model.where(delivery_state: %w[opened clicked]).count
      @open_rate = delivered_count.positive? ? (engaged.to_f / delivered_count * 100).round(1) : 0

      # Recent events
      @recent_delivery_events = Sincerely::DeliveryEvent.order(created_at: :desc).limit(5)
      @recent_engagement_events = Sincerely::EngagementEvent.order(created_at: :desc).limit(5)

      # Templates count
      @templates_count = Sincerely::Templates::NotificationTemplate.count
    end
  end
end
