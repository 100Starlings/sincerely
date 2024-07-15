# frozen_string_literal: true

module Sincerely
  def self.config
    @config ||= SincerelyConfig.new
  end

  class Error < StandardError; end
end
