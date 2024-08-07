# frozen_string_literal: true

require_relative 'config/sincerely_config'
require_relative 'config/application_config'
require_relative 'generators/sincerely/install_generator'
require_relative 'generators/sincerely/migration_generator'
require_relative 'generators/sincerely/aws_ses_webhook_controller_generator'
require_relative 'generators/sincerely/events_generator'
require_relative 'sincerely/delivery_systems/email_aws_ses'
require_relative 'sincerely/mixins/notification_model'
require_relative 'sincerely/mixins/webhooks/aws_ses_events'
require_relative 'sincerely/services/events/aws_ses_event'
require_relative 'sincerely/services/events/aws_ses_bounce_event'
require_relative 'sincerely/services/events/aws_ses_delivery_event'
require_relative 'sincerely/services/events/aws_ses_click_event'
require_relative 'sincerely/services/events/aws_ses_complaint_event'
require_relative 'sincerely/services/events/aws_ses_open_event'
require_relative 'sincerely/templates/email_liquid_template'
require_relative 'sincerely/version'
