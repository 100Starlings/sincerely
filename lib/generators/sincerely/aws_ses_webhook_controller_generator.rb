# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Sincerely
  module Generators
    class AwsSesWebhookControllerGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __dir__)

      desc 'Generates an AWS SES webhook controller and a route file.'

      def copy_initializer
        template('aws_ses_webhook_controller.rb.erb', "app/controllers/#{file_name}_controller.rb")
      end

      def routes_config
        destination_path = 'config/routes.rb'
        insert_into_file destination_path, after: 'Rails.application.routes.draw do' do
          routes_content
        end
      end

      private

      def routes_content
        "\n  resources :#{file_name}, only: :create"
      end
    end
  end
end
