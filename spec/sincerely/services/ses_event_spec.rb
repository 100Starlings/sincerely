# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe Sincerely::Services::SesEvent do
  subject(:ses_event) { described_class.new(event) }

  context 'when send event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/send.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'send',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2016-10-14T05:02:16.645Z')
      )
    end
  end

  context 'when bounce event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/bounce.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'bounce',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-05T00:41:02.669Z')
      )
    end
  end

  context 'when complaint event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/complaint.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'complaint',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-05T00:41:02.669Z')
      )
    end
  end

  context 'when delivery event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/delivery.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'delivery',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2016-10-19T23:21:04.133Z')
      )
    end
  end

  context 'when reject event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/reject.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'reject',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'sender@example.com',
        timestamp: Time.parse('2016-10-14T17:38:15.211Z')
      )
    end
  end

  context 'when open event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/open.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'open',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-09T22:00:19.652Z')
      )
    end
  end

  context 'when click event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/ses_events/click.json')) }

    it 'returns event properties' do
      expect(ses_event).to have_attributes(
        event_type: 'click',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-09T23:51:25.570Z')
      )
    end
  end
end
# rubocop:enable RSpec/ExampleLength
