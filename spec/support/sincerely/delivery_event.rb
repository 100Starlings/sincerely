# frozen_string_literal: true

module Sincerely
  class DeliveryEvent < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
    self.table_name = :sincerely_delivery_events

    serialize :options, coder: JSON
  end
end
