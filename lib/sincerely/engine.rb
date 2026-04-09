# frozen_string_literal: true

module Sincerely
  class Engine < ::Rails::Engine
    isolate_namespace Sincerely

    initializer 'sincerely.assets.precompile' do |app|
      app.config.assets.precompile += %w[sincerely.js] if app.config.respond_to?(:assets)
    end
  end
end
