# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesOpenEvent < AwsSesEvent
        def ip_address
          event.dig('open', 'ipAddress')
        end

        def user_agent
          event.dig('open', 'userAgent')
        end

        def link
          nil
        end

        def feedback_type
          nil
        end
      end
    end
  end
end
