# frozen_string_literal: true

module Sincerely
  class EngagementEventsController < ApplicationController
    def index
      @events = apply_time_filter(Sincerely::EngagementEvent).order(created_at: :desc)

      @events = @events.where(event_type: params[:event_type]) if params[:event_type].present?
      @events = @events.where('recipient LIKE ?', "%#{params[:recipient]}%") if params[:recipient].present?

      @pagination = paginate(@events)
      @events = @pagination[:records]

      @event_types = Sincerely::EngagementEvent.distinct.pluck(:event_type).compact
    end
  end
end
