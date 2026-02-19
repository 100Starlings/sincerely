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
        per_page:,
        total_pages: (total.to_f / per_page).ceil
      }
    end

    def time_filter_start
      case params[:period]
      when '1h' then 1.hour.ago
      when '24h', nil then 24.hours.ago
      when '7d' then 7.days.ago
      when '30d' then 30.days.ago
      when '3m' then 3.months.ago
      when 'all' then nil
      else 24.hours.ago
      end
    end

    def apply_time_filter(collection, column: :created_at)
      start_time = time_filter_start
      return collection unless start_time

      collection.where("#{column} >= ?", start_time)
    end
  end
end
