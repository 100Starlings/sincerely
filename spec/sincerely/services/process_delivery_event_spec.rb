# frozen_string_literal: true

require 'spec_helper'

describe Sincerely::Services::ProcessDeliveryEvent do
  describe '.call' do
    subject(:process) { described_class.call(event:) }

    let(:message_id) { '12345' }
    let(:notification) { Notification.create(recipient: 'john@doe.com', notification_type: 'email', message_id:) }
    let(:event) { double(:event, event_type:, message_id:) } # rubocop:disable RSpec/VerifiedDoubles

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
    end

    context 'when complaint event' do
      let(:event_type) { 'complaint' }

      it 'updates the status' do
        expect(notification.reload.complained?).to be true
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
    end

    context 'when click event' do
      let(:event_type) { 'click' }

      it 'updates the status' do
        expect(notification.reload.clicked?).to be true
      end
    end
  end
end
