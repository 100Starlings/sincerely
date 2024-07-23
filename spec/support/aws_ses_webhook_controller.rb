# frozen_string_literal: true

require 'sincerely/mixins/webhooks/aws_ses_events'

class AwsSesWebhookController < ApplicationController
  include Sincerely::Mixins::Webhooks::AwsSesEvents
end
