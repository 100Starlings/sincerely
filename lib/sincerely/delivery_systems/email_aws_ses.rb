# frozen_string_literal: true

require 'aws-sdk-sesv2'
require 'mail'

module Sincerely
  module DeliverySystems
    class EmailAwsSes
      DELIVERY_SYSTEM = :aws_ses2

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

      def email_options
        opts = { destination: { to_addresses: [notification.recipient] } }
        if attachments.present?
          opts[:content] = { raw: { data: raw_message } }
        else
          opts[:from_email_address] = template.sender
          opts[:content] = { simple: simple_content }
        end
        config_set = options[:configuration_set_name]
        opts = opts.merge(configuration_set_name: config_set) if config_set.present?
        opts
      end

      def simple_content
        {
          subject: { data: subject },
          body: {
            html: { data: notification.render_content(:html) },
            text: { data: notification.render_content(:text) }
          }
        }
      end

      def attachments
        notification.delivery_options_hash.fetch('attachments', [])
      end

      def raw_message
        message = Mail.new
        message.from = template.sender
        message.to = notification.recipient
        message.subject = subject

        cid_by_variable = attach_inline_images(message)
        text_body = notification.render_content(:text, cid_by_variable)
        html_body = notification.render_content(:html, cid_by_variable)

        message.text_part = Mail::Part.new { body text_body }
        message.html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body html_body
        end

        message.to_s
      end

      def attach_inline_images(message)
        attachments.each_with_object({}) do |attachment, cid_by_variable|
          message.attachments.inline[attachment['filename']] = {
            mime_type: attachment['mime_type'],
            content: attachment['content']
          }
          cid_by_variable[attachment['variable']] = message.attachments[attachment['filename']].url
        end
      end

      def subject
        raw_subject = notification.delivery_options_hash.fetch('subject', nil) || template.subject || ''
        template.renderer.render(raw_subject, notification.delivery_options_hash)
      end

      def update_notification(response)
        notification.update(message_id: response.message_id, delivery_system: DELIVERY_SYSTEM, sent_at: Time.current)
      end
    end
  end
end
