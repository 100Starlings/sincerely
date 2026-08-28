# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sincerely::NotificationsController', type: :request do
  describe 'GET /sincerely/notifications' do
    context 'with no notifications' do
      it 'returns success' do
        get '/sincerely/notifications'

        expect(response).to have_http_status(:ok)
      end

      it 'displays empty state' do
        get '/sincerely/notifications'

        expect(response.body).to include('Notifications')
      end
    end

    context 'with notifications' do
      before do
        5.times do |i|
          Notification.create!(
            recipient: "test#{i}@example.com",
            notification_type: 'email',
            delivery_state: 'delivered',
            created_at: i.hours.ago
          )
        end
      end

      it 'returns success' do
        get '/sincerely/notifications'

        expect(response).to have_http_status(:ok)
      end

      it 'displays notifications list' do
        get '/sincerely/notifications'

        expect(response.body).to include('test0@example.com')
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
        get '/sincerely/notifications'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Welcome Email')
      end
    end

    context 'with filters' do
      before do
        Notification.create!(
          recipient: 'delivered@example.com',
          notification_type: 'email',
          delivery_state: 'delivered',
          created_at: 1.hour.ago
        )
        Notification.create!(
          recipient: 'bounced@example.com',
          notification_type: 'sms',
          delivery_state: 'bounced',
          created_at: 2.hours.ago
        )
      end

      it 'filters by status' do
        get '/sincerely/notifications', params: { status: 'delivered' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('delivered@example.com')
        expect(response.body).not_to include('bounced@example.com')
      end

      it 'filters by recipient' do
        get '/sincerely/notifications', params: { recipient: 'delivered' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('delivered@example.com')
      end

      it 'filters by notification type' do
        get '/sincerely/notifications', params: { notification_type: 'sms' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('bounced@example.com')
      end
    end

    context 'with pagination' do
      before do
        30.times do |i|
          Notification.create!(
            recipient: "test#{i}@example.com",
            notification_type: 'email',
            delivery_state: 'delivered',
            created_at: i.minutes.ago
          )
        end
      end

      it 'paginates results' do
        get '/sincerely/notifications', params: { page: 1 }

        expect(response).to have_http_status(:ok)
      end

      it 'shows page 2' do
        get '/sincerely/notifications', params: { page: 2 }

        expect(response).to have_http_status(:ok)
      end

      it 'treats page=0 as page 1' do
        get '/sincerely/notifications', params: { page: 0 }

        expect(response).to have_http_status(:ok)
      end

      it 'treats negative page as page 1' do
        get '/sincerely/notifications', params: { page: -5 }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid date filters' do
      it 'ignores invalid date_from and returns success' do
        get '/sincerely/notifications', params: { date_from: 'not-a-date' }

        expect(response).to have_http_status(:ok)
      end

      it 'ignores invalid date_to and returns success' do
        get '/sincerely/notifications', params: { date_to: '99/99/9999' }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /sincerely/notifications/:id' do
    let!(:notification) do
      Notification.create!(
        recipient: 'show@example.com',
        notification_type: 'email',
        delivery_state: 'delivered',
        message_id: 'msg-show-123',
        created_at: 1.hour.ago
      )
    end

    it 'returns success' do
      get "/sincerely/notifications/#{notification.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'displays notification details' do
      get "/sincerely/notifications/#{notification.id}"

      expect(response.body).to include('show@example.com')
    end

    context 'with event timeline' do
      before do
        Sincerely::DeliveryEvent.create!(
          message_id: 'msg-show-123',
          event_type: 'delivery',
          recipient: 'show@example.com',
          timestamp: 1.hour.ago
        )

        Sincerely::EngagementEvent.create!(
          message_id: 'msg-show-123',
          event_type: 'open',
          recipient: 'show@example.com',
          timestamp: 30.minutes.ago
        )
      end

      it 'displays event timeline' do
        get "/sincerely/notifications/#{notification.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('delivery')
      end
    end

    context 'when notification has no message_id' do
      let!(:notification_without_message_id) do
        Notification.create!(
          recipient: 'no-message-id@example.com',
          notification_type: 'email',
          delivery_state: 'draft',
          message_id: nil
        )
      end

      it 'returns success without querying events' do
        get "/sincerely/notifications/#{notification_without_message_id.id}"

        expect(response).to have_http_status(:ok)
      end
    end

    it 'returns 404 for non-existent notification' do
      get '/sincerely/notifications/999999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
