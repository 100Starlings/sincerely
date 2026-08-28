# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sincerely::TemplatesController', type: :request do
  describe 'GET /sincerely/templates' do
    context 'with no templates' do
      it 'returns success' do
        get '/sincerely/templates'

        expect(response).to have_http_status(:ok)
      end

      it 'displays templates page' do
        get '/sincerely/templates'

        expect(response.body).to include('Templates')
      end
    end

    context 'with templates' do
      before do
        Sincerely::Templates::EmailLiquidTemplate.create!(
          name: 'Welcome Email',
          subject: 'Welcome!',
          sender: 'noreply@example.com',
          html_content: '<h1>Welcome</h1>',
          text_content: 'Welcome'
        )
      end

      it 'returns success' do
        get '/sincerely/templates'

        expect(response).to have_http_status(:ok)
      end

      it 'displays template list' do
        get '/sincerely/templates'

        expect(response.body).to include('Welcome Email')
      end
    end

    context 'with pagination' do
      before do
        30.times do |i|
          Sincerely::Templates::EmailLiquidTemplate.create!(
            name: "Template #{i}",
            subject: "Subject #{i}",
            sender: 'noreply@example.com',
            html_content: '<h1>Content</h1>',
            text_content: 'Content'
          )
        end
      end

      it 'paginates results' do
        get '/sincerely/templates', params: { page: 1 }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /sincerely/templates/new' do
    it 'returns success' do
      get '/sincerely/templates/new'

      expect(response).to have_http_status(:ok)
    end

    it 'displays new template form' do
      get '/sincerely/templates/new'

      expect(response.body).to include('Name')
      expect(response.body).to include('Subject')
    end
  end

  describe 'POST /sincerely/templates' do
    context 'with valid params' do
      let(:valid_params) do
        {
          template: {
            name: 'New Template',
            subject: 'New Subject',
            sender: 'sender@example.com',
            html_content: '<h1>HTML Content</h1>',
            text_content: 'Text Content'
          }
        }
      end

      it 'creates a template' do
        expect do
          post '/sincerely/templates', params: valid_params
        end.to change(Sincerely::Templates::NotificationTemplate, :count).by(1)
      end

      it 'redirects to template show page' do
        post '/sincerely/templates', params: valid_params

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          template: {
            name: '',
            subject: '',
            sender: '',
            html_content: '',
            text_content: ''
          }
        }
      end

      it 'does not create a template' do
        expect do
          post '/sincerely/templates', params: invalid_params
        end.not_to change(Sincerely::Templates::NotificationTemplate, :count)
      end

      it 'returns unprocessable entity' do
        post '/sincerely/templates', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /sincerely/templates/:id' do
    let!(:template) do
      Sincerely::Templates::EmailLiquidTemplate.create!(
        name: 'Show Template',
        subject: 'Show Subject',
        sender: 'show@example.com',
        html_content: '<h1>Show Content</h1>',
        text_content: 'Show Content'
      )
    end

    it 'returns success' do
      get "/sincerely/templates/#{template.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'displays template details' do
      get "/sincerely/templates/#{template.id}"

      expect(response.body).to include('Show Template')
      expect(response.body).to include('show@example.com')
    end
  end

  describe 'GET /sincerely/templates/:id/edit' do
    let!(:template) do
      Sincerely::Templates::EmailLiquidTemplate.create!(
        name: 'Edit Template',
        subject: 'Edit Subject',
        sender: 'edit@example.com',
        html_content: '<h1>Edit Content</h1>',
        text_content: 'Edit Content'
      )
    end

    it 'returns success' do
      get "/sincerely/templates/#{template.id}/edit"

      expect(response).to have_http_status(:ok)
    end

    it 'displays edit form with template data' do
      get "/sincerely/templates/#{template.id}/edit"

      expect(response.body).to include('Edit Template')
    end
  end

  describe 'PATCH /sincerely/templates/:id' do
    let!(:template) do
      Sincerely::Templates::EmailLiquidTemplate.create!(
        name: 'Original Template',
        subject: 'Original Subject',
        sender: 'original@example.com',
        html_content: '<h1>Original Content</h1>',
        text_content: 'Original Content'
      )
    end

    context 'with valid params' do
      let(:update_params) do
        {
          template: {
            name: 'Updated Template',
            subject: 'Updated Subject'
          }
        }
      end

      it 'updates the template' do
        patch "/sincerely/templates/#{template.id}", params: update_params

        template.reload
        expect(template.name).to eq('Updated Template')
      end

      it 'redirects to template show page' do
        patch "/sincerely/templates/#{template.id}", params: update_params

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          template: {
            name: ''
          }
        }
      end

      it 'returns unprocessable entity' do
        patch "/sincerely/templates/#{template.id}", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /sincerely/templates/:id/preview' do
    let!(:template) do
      Sincerely::Templates::EmailLiquidTemplate.create!(
        name: 'Preview Template',
        subject: 'Hello {{ name }}',
        sender: 'preview@example.com',
        html_content: '<h1>Hello {{ name }}</h1>',
        text_content: 'Hello {{ name }}'
      )
    end

    it 'returns success' do
      get "/sincerely/templates/#{template.id}/preview"

      expect(response).to have_http_status(:ok)
    end

    it 'renders template with sample data' do
      get "/sincerely/templates/#{template.id}/preview", params: { sample_data: '{"name": "John"}' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('John')
    end

    it 'returns bad request for invalid JSON' do
      get "/sincerely/templates/#{template.id}/preview", params: { sample_data: 'invalid json' }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
