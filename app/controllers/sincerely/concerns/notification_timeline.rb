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
        return {} if buckets.empty?

        interval = timeline_bucket_config[:interval].to_i
        start_epoch = buckets.first.to_i

        counts = notifications
                 .unscope(:order)
                 .group(:delivery_state, bucket_index_sql(start_epoch, interval))
                 .count

        counts.each_with_object({}) do |((state, raw_idx), count), series|
          idx = raw_idx.to_i
          next unless idx >= 0 && idx < buckets.length

          series[state] ||= Array.new(buckets.length, 0)
          series[state][idx] = count
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

      def bucket_index_sql(start_epoch, interval)
        epoch_sql = case ActiveRecord::Base.connection.adapter_name.downcase
                    when 'postgresql' then 'FLOOR(EXTRACT(EPOCH FROM created_at))'
                    when 'mysql2'     then 'FLOOR(UNIX_TIMESTAMP(created_at))'
                    else                   "CAST(strftime('%s', created_at) AS INTEGER)"
                    end
        Arel.sql("FLOOR((#{epoch_sql} - #{start_epoch}) / #{interval})")
      end
    end
  end
end
