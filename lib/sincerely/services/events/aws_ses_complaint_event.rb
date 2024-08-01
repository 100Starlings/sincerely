# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesComplaintEvent < AwsSesEvent
        def ip_address
          nil
        end

        def user_agent
          event.dig('complaint', 'userAgent')
        end

        def link
          nil
        end

        def feedback_type
          event.dig('complaint', 'complaintFeedbackType')
        end
      end
    end
  end
end
