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

      # Bounce rate
      bounced = filtered_notifications.where(delivery_state: 'bounced').count
      @bounce_rate = total_sent.positive? ? (bounced.to_f / total_sent * 100).round(1) : 0

      # Current period for display
      @current_period = params[:period] || '24h'

      @notifications_timeline = build_timeline_data(filtered_notifications)
    end

    private

    def build_timeline_data(notifications)
      bucket_config = timeline_bucket_config
      buckets = generate_time_buckets(bucket_config)
      interval = bucket_config[:interval]
      series = {}

      notifications.find_each do |notification|
        bucket_index = find_bucket_index(notification.created_at, buckets, interval)
        next if bucket_index.nil?

        state = notification.delivery_state
        series[state] ||= Array.new(buckets.length, 0)
        series[state][bucket_index] += 1
      end

      labels = buckets.map { |b| format_bucket_label(b, bucket_config) }

      { labels:, series:, buckets: }
    end

    def timeline_bucket_config
      case params[:period]
      when '1h'
        { interval: 5.minutes, format: '%H:%M', start: 1.hour.ago }
      when '24h', nil
        { interval: 1.hour, format: '%H:%M', start: 24.hours.ago }
      when '7d'
        { interval: 6.hours, format: '%a %H:%M', start: 7.days.ago }
      when '30d'
        { interval: 1.day, format: '%b %d', start: 30.days.ago }
      when '3m'
        { interval: 1.week, format: '%b %d', start: 3.months.ago }
      when 'all'
        { interval: 1.month, format: '%b %Y', start: 1.year.ago }
      else
        { interval: 1.hour, format: '%H:%M', start: 24.hours.ago }
      end
    end

    def generate_time_buckets(config)
      buckets = []
      current = config[:start].beginning_of_hour
      now = Time.current

      while current <= now
        buckets << current
        current += config[:interval]
      end

      buckets
    end

    def find_bucket_index(time, buckets, interval)
      return nil if buckets.empty?

      buckets.each_with_index do |bucket_start, index|
        bucket_end = bucket_start + interval
        return index if time >= bucket_start && time < bucket_end
      end

      buckets.length - 1 if time >= buckets.last && time < buckets.last + interval
    end

    def format_bucket_label(bucket, config)
      bucket.strftime(config[:format])
    end
  end
end
