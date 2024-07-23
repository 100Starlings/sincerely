# frozen_string_literal: true

require_relative 'config/sincerely_config'
require_relative 'config/application_config'
require_relative 'generators/sincerely/install_generator'
require_relative 'generators/sincerely/migration_generator'
require_relative 'generators/sincerely/events_generator'
require_relative 'sincerely/mixins/delivery_methods/events/bounce'
require_relative 'sincerely/mixins/delivery_methods/events/complaint'
require_relative 'sincerely/mixins/delivery_methods/events/engagement'
require_relative 'sincerely/mixins/notification_model'
require_relative 'sincerely/templates/email_liquid_template'
require_relative 'sincerely/delivery_methods/email_aws_ses'
require_relative 'sincerely/version'
