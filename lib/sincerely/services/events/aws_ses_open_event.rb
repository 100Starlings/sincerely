# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesOpenEvent < AwsSesEvent
        def options
          {
            ip_address: event.dig('open', 'ipAddress'),
            user_agent: event.dig('open', 'userAgent')
          }
        end
      end
    end
  end
end
