# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AwsSesWebhook' do
  let(:webhook_controller) { AwsSesWebhookController.new }

  describe 'create' do
    subject(:create) { webhook_controller.create }

    let(:configured_delivery_methods) { delivery_methods_config(topic_arn) }

    let(:verifier) { instance_double(Aws::SNS::MessageVerifier) }

    def topic_arn
      'arn:aws:sns:region:123456789012:sincerely-events'
    end

    def other_topic_arn
      'arn:aws:sns:region:210987654321:attacker-topic'
    end

    def delivery_methods_config(configured_topic_arn)
      instance_double(
        Sincerely::SincerelyConfig,
        delivery_methods: {
          'email' => {
            'delivery_system' => 'Sincerely::DeliverySystems::EmailAwsSes',
            'options' => {
              region: 'region', access_key_id: 'access_key_id', secret_access_key: 'secret_access_key',
              topic_arn: configured_topic_arn
            }
          }
        }
      )
    end

    before do
      allow(Aws::SNS::MessageVerifier).to receive(:new).and_return(verifier)
      allow(verifier).to receive(:authenticate!)
      allow(Sincerely).to(receive(:config).and_return(configured_delivery_methods))

      allow(webhook_controller).to receive(:render)
      allow(webhook_controller).to receive(:head)
      allow(webhook_controller.request).to receive(:raw_post).and_return(params.to_json)
    end

    context 'when SubscriptionConfirmation' do
      let(:client) { instance_double(Aws::SNS::Client) }

      let(:params) do
        {
          'Type' => 'SubscriptionConfirmation',
          'TopicArn' => topic_arn,
          'Token' => 'token'
        }
      end

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return(client)
        allow(client).to receive(:confirm_subscription)

        create
      end

      it 'calls verifier' do
        expect(verifier).to have_received(:authenticate!)
      end

      it 'confirms subscription' do
        expect(client).to have_received(:confirm_subscription).with(topic_arn:, token: 'token')
      end

      context 'when the TopicArn is not the configured one' do
        let(:params) do
          {
            'Type' => 'SubscriptionConfirmation',
            'TopicArn' => other_topic_arn,
            'Token' => 'token'
          }
        end

        it 'does not confirm the subscription' do
          expect(client).not_to have_received(:confirm_subscription)
        end

        it 'responds with forbidden' do
          expect(webhook_controller).to have_received(:head).with(:forbidden)
        end
      end

      context 'when no topic_arn is configured' do
        let(:configured_delivery_methods) { delivery_methods_config(nil) }

        it 'does not confirm the subscription' do
          expect(client).not_to have_received(:confirm_subscription)
        end

        it 'responds with forbidden' do
          expect(webhook_controller).to have_received(:head).with(:forbidden)
        end
      end
    end

    context 'when Notification' do
      let(:params) do
        {
          'Type' => 'Notification',
          'TopicArn' => topic_arn,
          'Message' => {}
        }
      end

      before do
        allow(Sincerely::Services::ProcessDeliveryEvent).to receive(:call)
        create
      end

      it 'calls ProcessDeliveryEvent' do
        expect(Sincerely::Services::ProcessDeliveryEvent)
          .to have_received(:call).with(event: instance_of(Sincerely::Services::Events::AwsSesEvent))
      end

      context 'when the TopicArn is not the configured one' do
        let(:params) do
          {
            'Type' => 'Notification',
            'TopicArn' => other_topic_arn,
            'Message' => {}
          }
        end

        it 'does not process the event' do
          expect(Sincerely::Services::ProcessDeliveryEvent).not_to have_received(:call)
        end

        it 'responds with forbidden' do
          expect(webhook_controller).to have_received(:head).with(:forbidden)
        end
      end
    end
  end
end
