# frozen_string_literal: true

require 'sincerely/renderers/liquid'

module Sincerely
  module Templates
    class NotificationTemplate < ::ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
      self.table_name = 'notification_templates'

      validates :name, presence: true

      def render(content_type, options = {})
        content = public_send("#{content_type}_content")
        renderer.render(content, options&.stringify_keys)
      end

      def renderer
        raise 'Method should be implemented in concrete class'
      end
    end
  end
end
