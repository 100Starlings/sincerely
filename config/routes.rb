# frozen_string_literal: true

Sincerely::Engine.routes.draw do
  root to: 'dashboard#index'

  resources :notifications, only: [:index, :show]

  resources :templates, except: [:destroy] do
    member do
      get :preview
    end
  end

  resources :delivery_events, only: [:index]
  resources :engagement_events, only: [:index]

  # Send emails
  get 'send', to: 'send#new', as: :send_new
  post 'send', to: 'send#create', as: :send_create
  get 'send/template_variables/:id', to: 'send#template_variables', as: :send_template_variables
end
