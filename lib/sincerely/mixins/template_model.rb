# frozen_string_literal: true

require 'active_support/concern'

module Sincerely
  module Mixins
    module TemplateModel
      extend ActiveSupport::Concern

      included do
        validates :name, presence: true
      end
    end
  end
end
