# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::DeliveryMethods::EmailAwsSes do
  describe 'call' do
    context 'when sending an email notification via Amazon SES' do
      let(:template) { Sincerely::Templates::EmailLiquidTemplate.create(subject: 'Spam') }
      let(:notification) { Notification.create(recipient: 'john@doe.com', notification_type: 'email', template:) }
      let(:options) { { region: 'region', access_key_id: 'access_key_id', secret_access_key: 'secret_access_key' } }
      let(:ses_client_response) { instance_double(Aws::SESV2::Types::SendEmailResponse, message_id: 1) }
      let(:ses_client) { instance_double(Aws::SESV2::Client, send_email: ses_client_response) }

      before { allow(Aws::SESV2::Client).to(receive(:new).and_return(ses_client)) }

      it 'sends the notification and updates the notification attributes' do
        described_class.call(notification:, options:)

        expect(ses_client).to(have_received(:send_email))
      end
    end
  end
end
