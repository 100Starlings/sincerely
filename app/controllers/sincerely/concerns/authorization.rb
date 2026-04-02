# frozen_string_literal: true

module Sincerely
  module Concerns
    module Authorization
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_user!
      end

      private

      def authenticate_user!
        return unless Sincerely.authenticate_with

        instance_exec(&Sincerely.authenticate_with)
      end
    end
  end
end
