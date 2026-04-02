# frozen_string_literal: true

module Sincerely
  class EngagementEventsController < ApplicationController
    include Concerns::EventFiltering

    def index
      @pagination = paginate(filtered_events)
      @events = @pagination[:records]
      @event_types = available_event_types
      @templates = available_templates
    end

    private

    def event_model
      Sincerely::EngagementEvent
    end
  end
end
