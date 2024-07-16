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

      def deliver # rubocop:disable Metrics/MethodLength
        response = client.send_email(
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
        )
        update_notification(response)
      end

      private

      attr_reader :notification, :template, :options

      def client
        @client ||= Aws::SESV2::Client.new(**options)
      end

      def subject
        notification.delivery_options&.fetch('subject', template.subject)
      end

      def update_notification(response)
        notification.update(message_id: response.message_id, delivery_system: :aws_ses2, sent_at: Time.current)
      end
    end
  end
end
