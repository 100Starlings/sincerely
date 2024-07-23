# frozen_string_literal: true

require 'sincerely/mixins/delivery_methods/events/bounce'

module Sincerely
  class BounceEvent < DeliveryEvent
    include Sincerely::Mixins::DeliveryMethods::Events::Bounce
  end
end
