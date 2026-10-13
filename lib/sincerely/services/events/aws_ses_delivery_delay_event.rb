# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesDeliveryDelayEvent < AwsSesEvent
        def event_type
          'delay'
        end

        def timestamp
          Time.parse(event.dig('deliveryDelay', 'timestamp') || event.dig('mail', 'timestamp')) # rubocop:disable Rails/TimeZone
        end

        def delivery_event_type
          event.dig('deliveryDelay', 'delayType')
        end

        def delivery_event_subtype
          nil
        end

        def options
          delayed_recipient = event.dig('deliveryDelay', 'delayedRecipients')&.first
          {
            status: delayed_recipient&.dig('status'),
            diagnostic_code: delayed_recipient&.dig('diagnosticCode'),
            expiration_time: event.dig('deliveryDelay', 'expirationTime')
          }
        end
      end
    end
  end
end
