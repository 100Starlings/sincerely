# frozen_string_literal: true

require 'anyway_config'

module Sincerely
  class SincerelyConfig < Anyway::Config
    config_name :sincerely

    attr_config(notification_model_name: 'Notification')
    attr_config(:delivery_methods)

    # Return navigation (optional)
    # Set return_url to show a "back to app" link in the footer
    attr_accessor :return_url, :return_label

    # Logout configuration (optional)
    # Set logout_url to show a logout button in the navigation
    # The button only appears when authentication is configured
    # Set logout_method to :delete for Devise (default is :get)
    attr_accessor :logout_url, :logout_label, :logout_method

    # Notification filtering (optional)
    # Lambda that returns a hash for where() clause to filter notifications
    # Example: -> { { recipient: session[:user_email] } }
    attr_accessor :filter_notifications_by

    def delivery_methods
      as_json.dig('values', 'delivery_methods')
    end
  end
end
