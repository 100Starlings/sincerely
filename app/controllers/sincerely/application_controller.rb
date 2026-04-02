# frozen_string_literal: true

module Sincerely
  class ApplicationController < ActionController::Base
    include Concerns::Authorization
    include Concerns::Pagination
    include Concerns::Periods
    include Concerns::Notifications

    protect_from_forgery with: :exception

    layout 'sincerely/application'
  end
end
