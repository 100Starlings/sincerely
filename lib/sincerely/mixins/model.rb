# frozen_string_literal: true

require 'active_support/concern'

module Sincerely
  module Mixins
    module Model
      extend ActiveSupport::Concern

      included do
        serialize :delivery_options, coder: JSON

        validates :recipient, presence: true
        validates :notification_type, inclusion: { in: %w[email sms push] }
      end
    end
  end
end
