# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesComplaintEvent < AwsSesEvent
        def options
          {
            complaint_feedback_type: event.dig('complaint', 'complaintFeedbackType'),
            user_agent: event.dig('complaint', 'userAgent')
          }
        end
      end
    end
  end
end
