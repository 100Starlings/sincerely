# frozen_string_literal: true

require 'anyway_config'

module Sincerely
  class SincerelyConfig < Anyway::Config
    config_name :sincerely

    attr_config(notification_model_name: 'Notification')
    attr_config(:delivery_methods)

    def delivery_methods
      as_json.dig('values', 'delivery_methods')
    end
  end
end
