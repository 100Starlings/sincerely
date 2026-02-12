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
end
