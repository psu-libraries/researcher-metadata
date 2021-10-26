# frozen_string_literal: true

class PreferredOpenAccessPolicy
  def initialize(open_access_locations)
    @open_access_locations = open_access_locations
  end

  def url
    rank_all.first&.url
  end

  def rank_all
    open_access_locations
      .filter { |loc| loc.url.present? }
      .sort_by { |loc| rank(loc) }
  end

  private

    attr_reader :open_access_locations

    def rank(location)
      source_rankings = [
        # Most preferred
        Source::SCHOLARSPHERE,
        Source::DICKINSON_IDEAS,
        Source::PSU_LAW_ELIBRARY,
        Source::OPEN_ACCESS_BUTTON,
        Source::UNPAYWALL,
        Source::USER
        # Least preferred
      ].map.with_index { |src, index| [src, index] }.to_h

      # Lower number = more preferred
      source_rank = source_rankings.fetch(location.source, 1000)
      is_best_rank = location.is_best ? 0 : 1

      [source_rank, is_best_rank]
    end
end
