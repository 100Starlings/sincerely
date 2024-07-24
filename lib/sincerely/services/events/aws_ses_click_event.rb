# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesClickEvent < AwsSesEvent
        def options
          {
            ip_address: event.dig('click', 'ipAddress'),
            user_agent: event.dig('click', 'userAgent'),
            link: event.dig('click', 'link')
          }
        end
      end
    end
  end
end
