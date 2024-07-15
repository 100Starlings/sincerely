# frozen_string_literal: true

require 'liquid'

module Sincerely
  module Renderers
    class Liquid
      def self.render(content, options = {})
        template = ::Liquid::Template.parse(content)
        template.render(options)
      end
    end
  end
end
