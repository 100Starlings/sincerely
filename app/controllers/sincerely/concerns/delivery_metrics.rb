# frozen_string_literal: true

module Sincerely
  module Concerns
    module DeliveryMetrics
      extend ActiveSupport::Concern

      EXCLUDED_FROM_SENT = %w[draft rejected].freeze
      DELIVERED_STATES = %w[delivered opened clicked].freeze
      ENGAGED_STATES = %w[opened clicked].freeze

      private_constant :EXCLUDED_FROM_SENT, :DELIVERED_STATES, :ENGAGED_STATES

      private

      def calculate_delivery_rate
        percentage(delivered_count, total_sent)
      end

      def calculate_open_rate
        percentage(engaged_count, delivered_count)
      end

      def calculate_bounce_rate
        percentage(bounced_count, total_sent)
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

      def percentage(numerator, denominator)
        return 0 unless denominator.positive?

        (numerator.to_f / denominator * 100).round(1)
      end
    end
  end
end
