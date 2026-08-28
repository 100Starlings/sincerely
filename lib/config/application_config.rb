# frozen_string_literal: true

module Sincerely
  class << self
    def config
      @config ||= SincerelyConfig.new
    end

    def notification_model
      config.notification_model_name.constantize
    end

    # Dashboard authentication hook
    attr_accessor :authenticate_with
  end

  class Error < StandardError; end
end
