# frozen_string_literal: true

module Sincerely
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      DEFAULT_PER_PAGE = 25
      private_constant :DEFAULT_PER_PAGE

      private

      def paginate(collection, per_page: DEFAULT_PER_PAGE)
        page = current_page
        total = collection.count

        {
          records: collection.offset(page_offset(page, per_page)).limit(per_page),
          total_count: total,
          current_page: page,
          per_page:,
          total_pages: total_pages(total, per_page)
        }
      end

      def current_page
        (params[:page] || 1).to_i
      end

      def page_offset(page, per_page)
        (page - 1) * per_page
      end

      def total_pages(total, per_page)
        (total.to_f / per_page).ceil
      end
    end
  end
end
