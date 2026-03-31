# frozen_string_literal: true

module Sincerely
  class ApplicationController < ActionController::Base
    VALID_PERIODS = %w[1h 24h 7d 30d 3m all].freeze
    DEFAULT_PERIOD = '24h'
    DEFAULT_PER_PAGE = 25

    PERIOD_DURATIONS = {
      '1h' => 1.hour,
      '24h' => 24.hours,
      '7d' => 7.days,
      '30d' => 30.days,
      '3m' => 3.months,
      'all' => nil
    }.freeze

    protect_from_forgery with: :exception

    layout 'sincerely/application'

    before_action :authenticate_user!

    helper_method :notification_model

    private

    def authenticate_user!
      return unless Sincerely.authenticate_with

      instance_exec(&Sincerely.authenticate_with)
    end

    def notification_model
      @notification_model ||= Sincerely.notification_model
    end

    def paginate(collection, per_page: DEFAULT_PER_PAGE)
      page = current_page
      total = collection.count

      {
        records: collection.offset(page_offset(page, per_page)).limit(per_page),
        total_count: total,
        current_page: page,
        per_page:,
        total_pages: total_pages(total, per_page)
      }
    end

    def current_page
      (params[:page] || 1).to_i
    end

    def page_offset(page, per_page)
      (page - 1) * per_page
    end

    def total_pages(total, per_page)
      (total.to_f / per_page).ceil
    end

    def current_period
      VALID_PERIODS.include?(params[:period]) ? params[:period] : DEFAULT_PERIOD
    end

    def time_filter_start
      duration = PERIOD_DURATIONS[current_period]
      duration&.ago
    end

    def apply_time_filter(collection, column: :created_at)
      return collection.all unless time_filter_start

      collection.where("#{column} >= ?", time_filter_start)
    end

    def apply_notification_filter(scope)
      return scope unless notification_filter_callable?

      conditions = notification_filter_conditions
      conditions.blank? ? scope : scope.where(conditions)
    end

    def apply_event_filter(scope)
      return scope unless notification_filter_callable?

      conditions = notification_filter_conditions
      return scope if conditions.blank?

      scope.where(message_id: filtered_message_ids_for_events(conditions))
    end

    def notification_filter_callable?
      Sincerely.config.filter_notifications_by.respond_to?(:call)
    end

    def notification_filter_conditions
      instance_exec(&Sincerely.config.filter_notifications_by)
    end

    def filtered_message_ids_for_events(conditions)
      notification_model.where(conditions).where.not(message_id: nil).pluck(:message_id)
    end
  end
end
