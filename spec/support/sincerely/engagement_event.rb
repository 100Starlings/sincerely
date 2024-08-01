# frozen_string_literal: true

module Sincerely
  class EngagementEvent < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
    self.table_name_prefix = :sincerely_

    serialize :options, coder: JSON
  end
end
