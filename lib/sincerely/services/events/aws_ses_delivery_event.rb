# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesDeliveryEvent < AwsSesEvent
        def delivery_event_type
          nil
        end

        def delivery_event_subtype
          nil
        end
      end
    end
  end
end
