# frozen_string_literal: true

module Sincerely
  module Concerns
    module NotificationTimeline
      extend ActiveSupport::Concern

      private

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
                                      oldest = filtered_notifications.minimum(:created_at) || 1.year.ago
                                      { interval: 1.month, format: '%b %Y', start: oldest }
                                    end
      end

      def generate_time_buckets
        config = timeline_bucket_config
        start_time = config[:start].beginning_of_hour
        (start_time.to_i..Time.current.to_i).step(config[:interval].to_i).map { |t| Time.zone.at(t) }
      end

      def find_bucket_index(time, buckets)
        return nil if buckets.empty?

        interval = timeline_bucket_config[:interval].to_i
        index = ((time.to_i - buckets.first.to_i) / interval).floor
        index if index >= 0 && index < buckets.length
      end
    end
  end
end
