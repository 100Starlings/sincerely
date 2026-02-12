# frozen_string_literal: true

module Sincerely
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    layout 'sincerely/application'

    before_action :authenticate_user!

    private

    def authenticate_user!
      return unless Sincerely.authenticate_with

      instance_exec(&Sincerely.authenticate_with)
    end

    def notification_model
      @notification_model ||= Sincerely.notification_model
    end

    def paginate(collection, per_page: 25)
      page = (params[:page] || 1).to_i
      offset = (page - 1) * per_page
      total = collection.count

      {
        records: collection.offset(offset).limit(per_page),
        total_count: total,
        current_page: page,
        per_page: per_page,
        total_pages: (total.to_f / per_page).ceil
      }
    end
  end
end
