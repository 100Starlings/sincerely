# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesBounceEvent < AwsSesEvent
        def delivery_event_type
          event.dig('bounce', 'bounceType')
        end

        def delivery_event_subtype
          event.dig('bounce', 'bounceSubType')
        end

        def options
          bounced_recipient = event.dig('bounce', 'bouncedRecipients')[0]
          {
            action: bounced_recipient&.dig('action'),
            status: bounced_recipient&.dig('status'),
            diagnostic_code: bounced_recipient&.dig('diagnosticCode')
          }
        end
      end
    end
  end
end
