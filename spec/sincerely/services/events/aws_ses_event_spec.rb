# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe Sincerely::Services::Events::AwsSesEvent do
  subject(:aws_ses_event) { described_class.event_for(event) }

  context 'when send event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/send.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'send',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2016-10-14T05:02:16.645Z')
      )
    end
  end

  context 'when bounce event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/bounce.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'bounce',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-05T00:41:02.669Z'),
        options: {
          bounce_type: 'Permanent',
          bounce_subtype: 'General',
          action: 'failed',
          status: '5.1.1',
          diagnostic_code: 'smtp; 550 5.1.1 user unknown'
        }
      )
    end
  end

  context 'when complaint event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/complaint.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'complaint',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-05T00:41:02.669Z'),
        options: {
          complaint_feedback_type: 'abuse',
          user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36' # rubocop:disable Layout/LineLength
        }
      )
    end
  end

  context 'when delivery event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/delivery.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'delivery',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2016-10-19T23:21:04.133Z')
      )
    end
  end

  context 'when reject event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/reject.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'reject',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'sender@example.com',
        timestamp: Time.parse('2016-10-14T17:38:15.211Z')
      )
    end
  end

  context 'when open event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/open.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'open',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-09T22:00:19.652Z'),
        options: {
          ip_address: '192.0.2.1',
          user_agent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_3 like Mac OS X) AppleWebKit/603.3.8 (KHTML, like Gecko) Mobile/14G60' # rubocop:disable Layout/LineLength
        }
      )
    end
  end

  context 'when click event' do
    let(:event) { JSON.parse(File.read('spec/sincerely/fixtures/aws_ses_events/click.json')) }

    it 'returns event properties' do
      expect(aws_ses_event).to have_attributes(
        event_type: 'click',
        message_id: 'EXAMPLE7c191be45-e9aedb9a-02f9-4d12-a87d-dd0099a07f8a-000000',
        recipient: 'recipient@example.com',
        timestamp: Time.parse('2017-08-09T23:51:25.570Z'),
        options: {
          ip_address: '192.0.2.1',
          user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36', # rubocop:disable Layout/LineLength
          link: 'http://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html'
        }
      )
    end
  end
end
# rubocop:enable RSpec/ExampleLength
