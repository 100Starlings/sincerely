# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def self.skip_before_action(*method); end

  def self.head(status); end
end
