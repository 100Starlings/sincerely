# frozen_string_literal: true

require 'sincerely/renderers/liquid'

module Sincerely
  module Templates
    class NotificationTemplate < ::ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
      TEMPLATE_TYPES = %w[liquid].freeze

      self.table_name = 'notification_templates'

      validates :name, presence: true
      validates :template_type, presence: true, inclusion: { in: TEMPLATE_TYPES }

      def render(content_type, options = {})
        content = public_send("#{content_type}_content")
        renderer.render(content, options&.stringify_keys)
      end

      private

      def renderer
        case template_type
        when 'liquid' then Sincerely::Renderers::Liquid
        end
      end
    end
  end
end
