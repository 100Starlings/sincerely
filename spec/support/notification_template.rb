# frozen_string_literal: true

require 'sincerely/mixins/template_model'

class NotificationTemplate < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  include Sincerely::Mixins::TemplateModel
end
