# frozen_string_literal: true

require 'sincerely/mixins/webhooks/ses_events'

class SesWebhookController < ApplicationController
  include Sincerely::Mixins::Webhooks::SesEvents
end
