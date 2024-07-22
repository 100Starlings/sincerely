# frozen_string_literal: true

require 'aws-sdk-sesv2'

module Sincerely
  module DeliveryMethods
    class EmailAwsSes
      class << self
        def call(notification:, options: {})
          new(notification:, options:).deliver
        end
      end

      def initialize(notification:, options:)
        @notification = notification
        @template = notification.template
        @options = options.symbolize_keys
      end

      def deliver
        response = client.send_email(email_options)
        update_notification(response)
      end

      private

      attr_reader :notification, :template, :options

      def client
        client_options = options.slice(:region, :access_key_id, :secret_access_key)
        @client ||= Aws::SESV2::Client.new(**client_options)
      end

      def email_options # rubocop:disable Metrics/MethodLength
        opts = {
          from_email_address: template.sender,
          destination: { to_addresses: [notification.recipient] },
          content: {
            simple: {
              subject: { data: subject },
              body: {
                html: {
                  data: notification.render_content(:html)
                },
                text: {
                  data: notification.render_content(:text)
                }
              }
            }
          }
        }
        config_set = options[:configuration_set_name]
        opts = opts.merge(configuration_set_name: config_set) if config_set.present?
        opts
      end

      def subject
        notification.delivery_options&.fetch('subject', nil) || template.subject
      end

      def update_notification(response)
        notification.update(message_id: response.message_id, delivery_system: :aws_ses2, sent_at: Time.current)
      end
    end
  end
end
