# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sincerely::DashboardController', type: :request do
  describe 'GET /sincerely' do
    context 'with no notifications' do
      it 'returns success' do
        get '/sincerely'

        expect(response).to have_http_status(:ok)
      end

      it 'displays zero totals' do
        get '/sincerely'

        expect(response.body).to include('Total Notifications')
        expect(response.body).to include('0')
      end
    end

    context 'with notifications' do
      before do
        Notification.create!(
          recipient: 'test@example.com',
          notification_type: 'email',
          delivery_state: 'delivered',
          created_at: 1.hour.ago
        )
        Notification.create!(
          recipient: 'test2@example.com',
          notification_type: 'email',
          delivery_state: 'opened',
          created_at: 2.hours.ago
        )
        Notification.create!(
          recipient: 'test3@example.com',
          notification_type: 'email',
          delivery_state: 'bounced',
          created_at: 3.hours.ago
        )
      end

      it 'returns success' do
        get '/sincerely'

        expect(response).to have_http_status(:ok)
      end

      it 'displays notification count' do
        get '/sincerely'

        expect(response.body).to include('3')
      end

      it 'displays delivery rate' do
        get '/sincerely'

        expect(response.body).to include('Delivery Rate')
      end

      it 'displays open rate' do
        get '/sincerely'

        expect(response.body).to include('Open Rate')
      end

      it 'displays bounce rate' do
        get '/sincerely'

        expect(response.body).to include('Bounce Rate')
      end

      it 'displays notifications by status chart' do
        get '/sincerely'

        expect(response.body).to include('Notifications by Status')
      end

      it 'displays notifications over time chart' do
        get '/sincerely'

        expect(response.body).to include('Notifications Over Time')
      end
    end

    context 'with time filter' do
      before do
        Notification.create!(
          recipient: 'recent@example.com',
          notification_type: 'email',
          delivery_state: 'delivered',
          created_at: 30.minutes.ago
        )
        Notification.create!(
          recipient: 'old@example.com',
          notification_type: 'email',
          delivery_state: 'delivered',
          created_at: 2.days.ago
        )
      end

      it 'filters by 1h period' do
        get '/sincerely', params: { period: '1h' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('1')
      end

      it 'filters by 24h period' do
        get '/sincerely', params: { period: '24h' }

        expect(response).to have_http_status(:ok)
      end

      it 'filters by 7d period' do
        get '/sincerely', params: { period: '7d' }

        expect(response).to have_http_status(:ok)
      end

      it 'filters by 30d period' do
        get '/sincerely', params: { period: '30d' }

        expect(response).to have_http_status(:ok)
      end

      it 'filters by 3m period' do
        get '/sincerely', params: { period: '3m' }

        expect(response).to have_http_status(:ok)
      end

      it 'shows all with all period' do
        get '/sincerely', params: { period: 'all' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with recent events' do
      before do
        Notification.create!(
          recipient: 'test@example.com',
          notification_type: 'email',
          delivery_state: 'delivered',
          message_id: 'msg-123',
          created_at: 1.hour.ago
        )

        Sincerely::DeliveryEvent.create!(
          message_id: 'msg-123',
          event_type: 'delivery',
          recipient: 'test@example.com',
          timestamp: 1.hour.ago
        )

        Sincerely::EngagementEvent.create!(
          message_id: 'msg-123',
          event_type: 'open',
          recipient: 'test@example.com',
          timestamp: 30.minutes.ago
        )
      end

      it 'displays recent delivery events' do
        get '/sincerely'

        expect(response.body).to include('Recent Delivery Events')
      end

      it 'displays recent engagement events' do
        get '/sincerely'

        expect(response.body).to include('Recent Engagement Events')
      end
    end
  end
end
