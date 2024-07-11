# frozen_string_literal: true

require 'sincerely/mixins/notification_model'

class Notification < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  include Sincerely::Mixins::NotificationModel
end
