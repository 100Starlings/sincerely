# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesClickEvent < AwsSesEvent
        def ip_address
          event.dig('click', 'ipAddress')
        end

        def user_agent
          event.dig('click', 'userAgent')
        end

        def link
          event.dig('click', 'link')
        end

        def feedback_type
          nil
        end
      end
    end
  end
end
