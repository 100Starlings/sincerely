# frozen_string_literal: true

require 'sincerely/mixins/model'

class Notification < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  include Sincerely::Mixins::Model
end
