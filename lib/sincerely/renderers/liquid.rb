# frozen_string_literal: true

module Sincerely
  module Renderers
    class Liquid
      def self.render(content, _options = {})
        content.to_s
      end
    end
  end
end
