# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::DeliverySystems::EmailAwsSes do
  describe 'call' do
    context 'when sending an email notification via Amazon SES' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:template) { Sincerely::Templates::EmailLiquidTemplate.create(subject: 'Spam') }
      let(:notification) { Notification.create(recipient: 'john@doe.com', notification_type: 'email', template:) }
      let(:options) do
        {
          region: 'region',
          access_key_id: 'access_key_id',
          secret_access_key: 'secret_access_key',
          configuration_set_name: 'config_set'
        }
      end
      let(:ses_client_response) { instance_double(Aws::SESV2::Types::SendEmailResponse, message_id: 1) }
      let(:ses_client) { instance_double(Aws::SESV2::Client, send_email: ses_client_response) }

      let(:expected_arguments) do
        {
          content: {
            simple: {
              body: {
                html: { data: '' },
                text: { data: '' }
              },
              subject: {
                data: 'Spam'
              }
            }
          },
          destination: { to_addresses: ['john@doe.com'] },
          from_email_address: nil,
          configuration_set_name: 'config_set'
        }
      end

      before do
        allow(Aws::SESV2::Client).to(receive(:new).and_return(ses_client))

        described_class.call(notification:, options:)
      end

      it 'sends the notification' do
        expect(ses_client).to(have_received(:send_email).with(expected_arguments))
      end

      it 'updates the attributes' do
        expect(notification.saved_changes.keys).to(include('delivery_system', 'sent_at', 'message_id'))
      end

      context 'when the subject is overridden by delivery_options' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:notification) do
          Notification.create(recipient: 'john@doe.com', notification_type: 'email',
                              delivery_options: { subject: 'Spam, Spam, Spam' }, template:)
        end

        let(:expected_arguments) do
          {
            content: {
              simple: {
                body: {
                  html: { data: '' },
                  text: { data: '' }
                },
                subject: {
                  data: 'Spam, Spam, Spam'
                }
              }
            },
            destination: { to_addresses: ['john@doe.com'] },
            from_email_address: nil,
            configuration_set_name: 'config_set'
          }
        end

        it 'uses the subject provided by the delivery options' do
          expect(ses_client).to(have_received(:send_email).with(expected_arguments))
        end
      end

      context 'when the notification has inline image attachments' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:template) do
          Sincerely::Templates::EmailLiquidTemplate.create(
            subject: 'Spam',
            sender: 'no-reply@example.com',
            html_content: '<img src="{{ icon_url }}">',
            text_content: 'icon: {{ icon_url }}'
          )
        end

        let(:notification) do
          Notification.create(
            recipient: 'john@doe.com',
            notification_type: 'email',
            template:,
            delivery_options: {
              attachments: [
                { variable: 'icon_url', filename: 'key.svg', mime_type: 'image/svg+xml', content: '<svg></svg>' }
              ]
            }
          )
        end

        it 'sends a raw MIME message instead of a simple one' do
          expect(ses_client).to(
            have_received(:send_email).with(a_hash_including(content: a_hash_including(:raw)))
          )
        end

        it 'embeds the image inline as its own MIME part' do
          expect(ses_client).to(
            have_received(:send_email).with(satisfy do |args|
              args[:content][:raw][:data].include?('Content-Type: image/svg+xml')
            end)
          )
        end

        it 'does not set from_email_address at the top level, since it is set in the raw MIME headers' do
          expect(ses_client).to(
            have_received(:send_email).with(satisfy { |args| !args.key?(:from_email_address) })
          )
        end
      end
    end
  end
end
