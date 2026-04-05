# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sincerely::SendController', type: :request do
  let!(:template) do
    Sincerely::Templates::EmailLiquidTemplate.create!(
      name: 'Test Template',
      subject: 'Hello',
      sender: 'noreply@example.com',
      html_content: '<p>Hello</p>',
      text_content: 'Hello'
    )
  end

  describe 'POST /sincerely/send' do
    context 'when recipients exceed the limit' do
      let(:too_many_recipients) do
        (1..51).map { |i| "user#{i}@example.com" }.join(', ')
      end

      it 'returns an error' do
        post '/sincerely/send', params: { recipients: too_many_recipients, template_id: template.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to include('Maximum 50 recipients')
      end
    end

    context 'when no valid recipients are provided' do
      it 'returns an error' do
        post '/sincerely/send', params: { recipients: 'not-an-email', template_id: template.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to include('No valid recipients')
      end
    end

    context 'when template is not found' do
      it 'returns an error' do
        post '/sincerely/send', params: { recipients: 'user@example.com', template_id: 999_999 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to include('Template not found')
      end
    end
  end
end
