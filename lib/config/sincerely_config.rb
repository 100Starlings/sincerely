# frozen_string_literal: true

module Sincerely
  class SincerelyConfig < ApplicationConfig
    config_name :sincerely

    attr_config(
      notification_model_name: 'Notification',
      template_model_name: 'NotificationTemplate'
    )
  end
end
