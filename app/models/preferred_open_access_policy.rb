# frozen_string_literal: true

class PreferredOpenAccessPolicy
  def initialize(publication)
    @publication = publication
  end

  delegate :open_access_locations, to: :publication

  def url
    open_access_locations
      .filter { |loc| loc.url.present? }
      .min_by { |loc| rank(loc) }
      .try(:url)
  end

  private

    attr_reader :publication

    def rank(location)
      source_rankings = [
        # Most preferred
        Source::SCHOLARSPHERE,
        Source::OPEN_ACCESS_BUTTON,
        Source::UNPAYWALL,
        Source::DICKINSON_IDEAS,
        Source::PSU_LAW_ELIBRARY,
        Source::USER
        # Least preferred
      ].map.with_index { |src, index| [src, index] }.to_h

      # Lower number = more preferred
      source_rank = source_rankings.fetch(location.source, 1000)
      is_best_rank = location.is_best ? 0 : 1

      [source_rank, is_best_rank]
    end
end
