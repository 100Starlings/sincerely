# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesBounceEvent < AwsSesEvent
        def options
          bounced_recipient = event.dig('bounce', 'bouncedRecipients')[0]
          {
            bounce_type: event.dig('bounce', 'bounceType'),
            bounce_subtype: event.dig('bounce', 'bounceSubType'),
            action: bounced_recipient&.dig('action'),
            status: bounced_recipient&.dig('status'),
            diagnostic_code: bounced_recipient&.dig('diagnosticCode')
          }
        end
      end
    end
  end
end
