# frozen_string_literal: true

module Sincerely
  module ApplicationHelper
    def state_badge_class(state)
      case state.to_s
      when 'draft' then 'badge-draft'
      when 'accepted' then 'badge-accepted'
      when 'delivered' then 'badge-delivered'
      when 'opened' then 'badge-opened'
      when 'clicked' then 'badge-clicked'
      when 'bounced' then 'badge-bounced'
      when 'complained' then 'badge-complained'
      when 'rejected' then 'badge-rejected'
      when 'delayed' then 'badge-delayed'
      else 'badge-default'
      end
    end

    def format_timestamp(time)
      return '-' unless time

      time.strftime('%b %d, %Y %H:%M:%S')
    end

    def event_timestamp(event)
      event.timestamp || event.created_at
    end

    def format_event_options(options)
      return nil if options.blank?

      JSON.pretty_generate(options)
    rescue JSON::GeneratorError
      options.to_s
    end

    def event_type_badge_class(event_type)
      case event_type.to_s.downcase
      when 'delivery', 'send' then 'badge-delivered'
      when 'open' then 'badge-opened'
      when 'click' then 'badge-clicked'
      when 'bounce', 'hard_bounce', 'soft_bounce' then 'badge-bounced'
      when 'complaint', 'spam_complaint' then 'badge-complained'
      when 'reject' then 'badge-rejected'
      when 'delay' then 'badge-delayed'
      else 'badge-default'
      end
    end
  end
end
