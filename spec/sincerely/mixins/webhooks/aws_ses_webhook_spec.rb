# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AwsSesWebhook' do
  let(:webhook_controller) { AwsSesWebhookController.new }

  describe 'create' do
    subject(:create) { webhook_controller.create }

    let(:configured_delivery_methods) do
      instance_double(
        Sincerely::SincerelyConfig,
        delivery_methods: {
          'email' => {
            'class_name' => 'Sincerely::DeliverySystems::EmailAwsSes',
            'options' => { region: 'region', access_key_id: 'access_key_id', secret_access_key: 'secret_access_key' }
          }
        }
      )
    end

    let(:verifier) { instance_double(Aws::SNS::MessageVerifier) }

    before do
      allow(Aws::SNS::MessageVerifier).to receive(:new).and_return(verifier)
      allow(verifier).to receive(:authenticate!)
      allow(Sincerely).to(receive(:config).and_return(configured_delivery_methods))

      allow(webhook_controller).to receive(:render)
      allow(webhook_controller.request).to receive(:raw_post).and_return(params.to_json)
    end

    context 'when SubscriptionConfirmation' do
      let(:client) { instance_double(Aws::SNS::Client) }

      let(:params) do
        {
          'Type' => 'SubscriptionConfirmation',
          'TopicArn' => 'arn',
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
        expect(client).to have_received(:confirm_subscription).with(topic_arn: 'arn', token: 'token')
      end
    end

    context 'when Notification' do
      let(:params) do
        {
          'Type' => 'Notification',
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
    end
  end
end
