# frozen_string_literal: true

module Statistics
  extend ActiveSupport::Concern

  included do
    def percent_open_access
      ((open_access_article_count.to_f / total_article_count) * 100).round 1
    end
  end
end
