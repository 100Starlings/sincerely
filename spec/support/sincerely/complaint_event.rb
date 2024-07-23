# frozen_string_literal: true

require 'sincerely/mixins/delivery_methods/events/complaint'

module Sincerely
  class ComplaintEvent < DeliveryEvent
    include Sincerely::Mixins::DeliveryMethods::Events::Complaint
  end
end
