# frozen_string_literal: true

module Sincerely
  class NotificationsController < ApplicationController
    include Concerns::Pagination
    include Concerns::Periods
    include Concerns::EventTimeline

    def index
      @pagination = paginate(filtered_notifications)
      @notifications = @pagination[:records]
      @templates = available_templates
      @states = available_states
    end

    def show
      @notification = find_notification
      @template = @notification.template
      @timeline = build_event_timeline
    end

    private

    def filtered_notifications
      scope = base_notifications_scope
      scope = filter_by_status(scope)
      scope = filter_by_template(scope)
      scope = filter_by_recipient(scope)
      scope = filter_by_notification_type(scope)
      filter_by_date_range(scope)
    end

    def base_notifications_scope
      apply_notification_filter(apply_time_filter(notification_model)).includes(:template).order(created_at: :desc)
    end

    def filter_by_status(scope)
      return scope if params[:status].blank?

      scope.where(delivery_state: params[:status])
    end

    def filter_by_template(scope)
      return scope if params[:template_id].blank?

      scope.where(template_id: params[:template_id])
    end

    def filter_by_recipient(scope)
      return scope if params[:recipient].blank?

      scope.where('recipient LIKE ?', "%#{params[:recipient]}%")
    end

    def filter_by_notification_type(scope)
      return scope if params[:notification_type].blank?

      scope.where(notification_type: params[:notification_type])
    end

    def filter_by_date_range(scope)
      date_from = safe_parse_date(params[:date_from])
      date_to   = safe_parse_date(params[:date_to])

      scope = scope.where(created_at: date_from..) if date_from
      scope = scope.where(created_at: ..date_to.end_of_day) if date_to
      scope
    end

    def safe_parse_date(value)
      Date.iso8601(value) if value.present?
    rescue ArgumentError
      nil
    end

    def find_notification
      apply_notification_filter(notification_model).find(params[:id])
    end

    def available_templates
      Sincerely::Templates::NotificationTemplate.all
    end

    def available_states
      notification_model.aasm.states.map(&:name)
    end
  end
end
