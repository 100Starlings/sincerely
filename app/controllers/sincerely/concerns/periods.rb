# frozen_string_literal: true

module Sincerely
  module Concerns
    module Periods
      extend ActiveSupport::Concern

      VALID_PERIODS = %w[1h 24h 7d 30d 3m all].freeze
      DEFAULT_PERIOD = '24h'

      PERIOD_DURATIONS = {
        '1h' => 1.hour,
        '24h' => 24.hours,
        '7d' => 7.days,
        '30d' => 30.days,
        '3m' => 3.months,
        'all' => nil
      }.freeze

      private_constant :VALID_PERIODS, :DEFAULT_PERIOD, :PERIOD_DURATIONS

      private

      def current_period
        VALID_PERIODS.include?(params[:period]) ? params[:period] : DEFAULT_PERIOD
      end

      def time_filter_start
        duration = PERIOD_DURATIONS[current_period]
        duration&.ago
      end

      def apply_time_filter(collection, column: :created_at)
        return collection.all unless time_filter_start

        collection.where("#{column} >= ?", time_filter_start)
      end
    end
  end
end
