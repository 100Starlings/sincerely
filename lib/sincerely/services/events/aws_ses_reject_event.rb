# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesRejectEvent < AwsSesEvent
        def rejection_reason
          event.dig('reject', 'reason')
        end
      end
    end
  end
end
