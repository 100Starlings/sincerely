# frozen_string_literal: true

module Sincerely
  class DashboardController < ApplicationController
    EXCLUDED_FROM_SENT = %w[draft rejected].freeze
    DELIVERED_STATES = %w[delivered opened clicked].freeze
    ENGAGED_STATES = %w[opened clicked].freeze

    def index
      @total_notifications = filtered_notifications.count
      @notifications_by_state = filtered_notifications.group(:delivery_state).count
      @recent_notifications = filtered_notifications.order(created_at: :desc).limit(10)
      @delivery_rate = calculate_delivery_rate
      @open_rate = calculate_open_rate
      @bounce_rate = calculate_bounce_rate
      @recent_delivery_events = recent_delivery_events
      @recent_engagement_events = recent_engagement_events
      @current_period = current_period
      @notifications_timeline = build_timeline_data(filtered_notifications)
    end

    private

    def filtered_notifications
      @filtered_notifications ||= apply_notification_filter(apply_time_filter(notification_model))
    end

    def total_sent
      @total_sent ||= filtered_notifications.where.not(delivery_state: EXCLUDED_FROM_SENT).count
    end

    def delivered_count
      @delivered_count ||= filtered_notifications.where(delivery_state: DELIVERED_STATES).count
    end

    def engaged_count
      @engaged_count ||= filtered_notifications.where(delivery_state: ENGAGED_STATES).count
    end

    def bounced_count
      @bounced_count ||= filtered_notifications.where(delivery_state: 'bounced').count
    end

    def calculate_delivery_rate
      percentage(delivered_count, total_sent)
    end

    def calculate_open_rate
      percentage(engaged_count, delivered_count)
    end

    def calculate_bounce_rate
      percentage(bounced_count, total_sent)
    end

    def percentage(numerator, denominator)
      return 0 unless denominator.positive?

      (numerator.to_f / denominator * 100).round(1)
    end

    def user_message_ids
      @user_message_ids ||= filtered_notifications.where.not(message_id: nil).pluck(:message_id)
    end

    def recent_delivery_events
      apply_time_filter(Sincerely::DeliveryEvent)
        .where(message_id: user_message_ids)
        .order(created_at: :desc)
        .limit(5)
    end

    def recent_engagement_events
      apply_time_filter(Sincerely::EngagementEvent)
        .where(message_id: user_message_ids)
        .order(created_at: :desc)
        .limit(5)
    end

    def build_timeline_data(notifications)
      buckets = generate_time_buckets
      series = build_timeline_series(notifications, buckets)
      labels = buckets.map { |b| b.strftime(timeline_bucket_config[:format]) }

      { labels:, series:, buckets: }
    end

    def build_timeline_series(notifications, buckets)
      notifications.each_with_object({}) do |notification, series|
        bucket_index = find_bucket_index(notification.created_at, buckets)
        next unless bucket_index

        state = notification.delivery_state
        series[state] ||= Array.new(buckets.length, 0)
        series[state][bucket_index] += 1
      end
    end

    def timeline_bucket_config
      @timeline_bucket_config ||= case current_period
      when '1h'
        { interval: 5.minutes, format: '%H:%M', start: 1.hour.ago }
      when '24h'
        { interval: 1.hour, format: '%H:%M', start: 24.hours.ago }
      when '7d'
        { interval: 6.hours, format: '%a %H:%M', start: 7.days.ago }
      when '30d'
        { interval: 1.day, format: '%b %d', start: 30.days.ago }
      when '3m'
        { interval: 1.week, format: '%b %d', start: 3.months.ago }
      when 'all'
        { interval: 1.month, format: '%b %Y', start: 1.year.ago }
      end
    end

    def generate_time_buckets
      config = timeline_bucket_config
      start_time = config[:start].beginning_of_hour
      (start_time.to_i..Time.current.to_i).step(config[:interval]).map { |t| Time.zone.at(t) }
    end

    def find_bucket_index(time, buckets)
      interval = timeline_bucket_config[:interval]
      buckets.index { |bucket| time >= bucket && time < bucket + interval }
    end
  end
end
