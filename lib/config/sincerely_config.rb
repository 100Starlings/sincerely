# frozen_string_literal: true

require 'anyway_config'

module Sincerely
  class SincerelyConfig < Anyway::Config
    config_name :sincerely

    attr_config(
      notification_model_name: 'Notification'
    )
  end
end
