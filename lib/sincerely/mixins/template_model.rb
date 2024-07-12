# frozen_string_literal: true

require 'active_support/concern'
require 'sincerely/renderers/liquid'

module Sincerely
  module Mixins
    module TemplateModel
      extend ActiveSupport::Concern

      TEMPLATE_TYPES = %w[liquid].freeze

      included do
        validates :name, presence: true
        validates :template_type, presence: true, inclusion: { in: TEMPLATE_TYPES }

        def render(content_type, options = {})
          content = public_send("#{content_type}_content")
          renderer.render(content, options)
        end

        private

        def renderer
          case template_type
          when 'liquid' then Sincerely::Renderers::Liquid
          end
        end
      end

      class_methods do
        def create_template(template_type, **options)
          create(**options.merge(template_type:))
        end
      end
    end
  end
end
