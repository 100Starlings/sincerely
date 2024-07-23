# frozen_string_literal: true

require 'sincerely/mixins/delivery_methods/events/engagement'

module Sincerely
  class EngagementEvent < DeliveryEvent
    include Sincerely::Mixins::DeliveryMethods::Events::Engagement
  end
end
