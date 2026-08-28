# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sincerely::EngagementEventsController', type: :request do
  describe 'GET /sincerely/engagement_events' do
    context 'with no events' do
      it 'returns success' do
        get '/sincerely/engagement_events'

        expect(response).to have_http_status(:ok)
      end

      it 'displays engagement events page' do
        get '/sincerely/engagement_events'

        expect(response.body).to include('Engagement')
      end
    end

    context 'with events' do
      before do
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-1',
          event_type: 'open',
          recipient: 'opened@example.com',
          timestamp: 1.hour.ago
        )
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-2',
          event_type: 'click',
          recipient: 'clicked@example.com',
          link: 'https://example.com/link',
          timestamp: 2.hours.ago
        )
      end

      it 'returns success' do
        get '/sincerely/engagement_events'

        expect(response).to have_http_status(:ok)
      end

      it 'displays events list' do
        get '/sincerely/engagement_events'

        expect(response.body).to include('opened@example.com')
        expect(response.body).to include('clicked@example.com')
      end
    end

    context 'with templates available' do
      before do
        Sincerely::Templates::EmailLiquidTemplate.create!(
          name: 'Welcome Email',
          subject: 'Welcome!',
          sender: 'noreply@example.com',
          html_content: '<h1>Welcome</h1>',
          text_content: 'Welcome'
        )
      end

      it 'renders the template filter options' do
        get '/sincerely/engagement_events'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Welcome Email')
      end
    end

    context 'with filters' do
      before do
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-1',
          event_type: 'open',
          recipient: 'opened@example.com',
          timestamp: 1.hour.ago
        )
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-2',
          event_type: 'click',
          recipient: 'clicked@example.com',
          timestamp: 2.hours.ago
        )
      end

      it 'filters by event_type' do
        get '/sincerely/engagement_events', params: { event_type: 'open' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('opened@example.com')
      end

      it 'filters by recipient' do
        get '/sincerely/engagement_events', params: { recipient: 'clicked' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('clicked@example.com')
      end
    end

    context 'with time filter' do
      before do
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-recent',
          event_type: 'open',
          recipient: 'recent@example.com',
          timestamp: 30.minutes.ago,
          created_at: 30.minutes.ago
        )
        Sincerely::EngagementEvent.create!(
          message_id: 'msg-old',
          event_type: 'open',
          recipient: 'old@example.com',
          timestamp: 2.days.ago,
          created_at: 2.days.ago
        )
      end

      it 'filters by 1h period' do
        get '/sincerely/engagement_events', params: { period: '1h' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('recent@example.com')
        expect(response.body).not_to include('old@example.com')
      end

      it 'shows all with all period' do
        get '/sincerely/engagement_events', params: { period: 'all' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('recent@example.com')
        expect(response.body).to include('old@example.com')
      end
    end

    context 'with pagination' do
      before do
        30.times do |i|
          Sincerely::EngagementEvent.create!(
            message_id: "msg-#{i}",
            event_type: 'open',
            recipient: "test#{i}@example.com",
            timestamp: i.minutes.ago
          )
        end
      end

      it 'paginates results' do
        get '/sincerely/engagement_events', params: { page: 1 }

        expect(response).to have_http_status(:ok)
      end

      it 'shows page 2' do
        get '/sincerely/engagement_events', params: { page: 2 }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
