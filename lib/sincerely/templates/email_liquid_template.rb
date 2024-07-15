# frozen_string_literal: true

require 'sincerely/templates/notification_template'

module Sincerely
  module Templates
    class EmailLiquidTemplate < NotificationTemplate
      def renderer
        Sincerely::Renderers::Liquid
      end
    end
  end
end
