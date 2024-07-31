# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable Rails/TimeZone
describe Sincerely::Services::ProcessDeliveryEvent do
  describe '.call' do
    subject(:process) { described_class.call(event:) }

    let(:message_id) { '12345' }
    let(:recipient) { 'john@doe.com' }
    let(:timestamp) { '2024-07-01T00:40:02.012Z' }
    let(:timestamp_parsed) { Time.parse(timestamp) }
    let(:delivery_system) { 'aws_ses2' }
    let(:notification) { Notification.create(recipient:, notification_type: 'email', message_id:) }
    let(:options) { { 'userAgent' => 'agent' } }
    let(:event) do
      double(:event, event_type:, message_id:, recipient:, timestamp:, options:, delivery_system:) # rubocop:disable RSpec/VerifiedDoubles
    end

    before do
      notification
      allow(Sincerely).to receive(:config)
        .and_return(instance_double(Sincerely::SincerelyConfig, notification_model_name: 'Notification'))
      process
    end

    context 'when send event' do
      let(:event_type) { 'send' }

      it 'updates the status' do
        expect(notification.reload.accepted?).to be true
      end
    end

    context 'when bounce event' do
      let(:event_type) { 'bounce' }

      it 'updates the status' do
        expect(notification.reload.bounced?).to be true
      end

      it 'creates an event record' do
        expect(Sincerely::DeliveryEvent.first)
          .to(have_attributes(message_id:, delivery_system:, event_type:, recipient:, timestamp: timestamp_parsed,
                              options:))
      end
    end

    context 'when complaint event' do
      let(:event_type) { 'complaint' }

      it 'updates the status' do
        expect(notification.reload.complained?).to be true
      end

      it 'creates an event record' do
        expect(Sincerely::DeliveryEvent.first)
          .to(have_attributes(message_id:, delivery_system:, event_type:, recipient:, timestamp: timestamp_parsed,
                              options:))
      end
    end

    context 'when delivery event' do
      let(:event_type) { 'delivery' }

      it 'updates the status' do
        expect(notification.reload.delivered?).to be true
      end
    end

    context 'when reject event' do
      let(:event) { double(:event, event_type:, message_id:, rejection_reason: 'rejected') } # rubocop:disable RSpec/VerifiedDoubles
      let(:event_type) { 'reject' }

      it 'updates the status' do
        expect(notification.reload).to have_attributes(rejected?: true, error_message: 'rejected')
      end
    end

    context 'when open event' do
      let(:event_type) { 'open' }

      it 'updates the status' do
        expect(notification.reload.opened?).to be true
      end

      it 'creates an event record' do
        expect(Sincerely::DeliveryEvent.first)
          .to(have_attributes(message_id:, delivery_system:, event_type:, recipient:, timestamp: timestamp_parsed,
                              options:))
      end
    end

    context 'when click event' do
      let(:event_type) { 'click' }

      it 'updates the status' do
        expect(notification.reload.clicked?).to be true
      end

      it 'creates an event record' do
        expect(Sincerely::DeliveryEvent.first)
          .to(have_attributes(message_id:, delivery_system:, recipient:, timestamp: Time.parse(timestamp), options:))
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
# rubocop:enable Rails/TimeZone
