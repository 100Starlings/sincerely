# frozen_string_literal: true

require 'aasm'
require 'active_support/concern'

module Sincerely
  module Mixins
    module NotificationModel
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
        include AASM

        serialize :delivery_options, coder: JSON

        belongs_to :template, class_name: 'Sincerely::Templates::NotificationTemplate'

        validates :recipient, presence: true
        validates :notification_type, inclusion: { in: %w[email sms push] }

        aasm column: :delivery_state do # rubocop:disable Metrics/BlockLength
          state :draft, initial: true
          state :accepted
          state :rejected
          state :delivered
          state :bounced
          state :complained
          state :delayed
          state :opened
          state :clicked

          event :set_accepted do
            transitions to: :accepted, from: [:draft]
          end

          event :set_rejected do
            transitions to: :rejected
          end

          event :set_delivered do
            transitions to: :delivered
          end

          event :set_bounced do
            transitions to: :bounced
          end

          event :set_complained do
            transitions to: :complained
          end

          event :set_delayed do
            transitions to: :delayed
          end

          event :set_opened do
            transitions to: :opened
          end

          event :set_clicked do
            transitions to: :clicked
          end
        end

        def render_content(content_type)
          template.render(content_type, delivery_options)
        end

        def deliver
          raise StandardError, "Delivery method not configured for #{notification_type}." if delivery_method.blank?

          call_delivery_method
        end

        private

        def delivery_method
          @delivery_method ||= Sincerely.config.delivery_methods&.fetch(notification_type, {})
        end

        def call_delivery_method
          class_name, options = delivery_method.values_at('delivery_system', 'options')
          klass = class_name.constantize
          klass.call(notification: self, options:)
        end
      end
    end
  end
end
