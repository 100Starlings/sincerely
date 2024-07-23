# frozen_string_literal: true

require 'active_support/concern'
require 'aws-sdk-sns'

require 'sincerely/services/process_delivery_event'
require 'sincerely/services/aws_ses_event'

module Sincerely
  module Mixins
    module Webhooks
      module AwsSesEvents
        extend ActiveSupport::Concern

        included do # rubocop:disable Metrics/BlockLength
          skip_before_action :verify_authenticity_token, only: [:create]

          def create
            verifier.authenticate!(request.raw_post)

            case sns_message_type
            when 'SubscriptionConfirmation'
              confirm_subscription
            when 'Notification'
              logger&.info event_payload # temporary log
              event = Sincerely::Services::AwsSesEvent.new(event_payload)
              Sincerely::Services::ProcessDeliveryEvent.call(event:)
            end

            render json: { message: 'ok' }, status: :ok
          end

          private

          def verifier
            @verifier ||= Aws::SNS::MessageVerifier.new
          end

          def posted_message_body
            @posted_message_body ||= JSON.parse(request.raw_post)
          end

          def sns_message_type
            posted_message_body['Type']
          end

          def topic_arn
            posted_message_body['TopicArn']
          end

          def token
            posted_message_body['Token']
          end

          def event_payload
            message = posted_message_body['Message']
            JSON.parse(message) if message.present?
          end

          def delivery_options
            Sincerely.config.delivery_methods.dig('email', 'options').symbolize_keys
          end

          def confirm_subscription
            client_options = delivery_options.slice(:region, :access_key_id, :secret_access_key)
            client = Aws::SNS::Client.new(**client_options)

            client.confirm_subscription(topic_arn:, token:)
          end
        end
      end
    end
  end
end
