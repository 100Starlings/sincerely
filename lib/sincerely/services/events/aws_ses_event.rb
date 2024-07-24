# frozen_string_literal: true

module Sincerely
  module Services
    module Events
      class AwsSesEvent
        attr_reader :event

        class << self
          def event_for(event_payload)
            case event_type(event_payload)
            when 'click' then AwsSesClickEvent.new(event_payload)
            when 'open' then AwsSesOpenEvent.new(event_payload)
            when 'bounce' then AwsSesBounceEvent.new(event_payload)
            when 'complaint' then AwsSesComplaintEvent.new(event_payload)
            else new(event_payload)
            end
          end

          def event_type(event_payload)
            event_payload&.dig('eventType')&.downcase
          end
        end

        def initialize(event_payload)
          @event = event_payload
        end

        def event_type
          self.class.event_type(event)
        end

        def message_id
          event.dig('mail', 'messageId')
        end

        def recipient
          event.dig('mail', 'destination')[0]
        end

        def timestamp
          Time.parse(event.dig(event_type, 'timestamp') || event.dig('mail', 'timestamp')) # rubocop:disable Rails/TimeZone
        end

        def options
          nil
        end
      end
    end
  end
end
