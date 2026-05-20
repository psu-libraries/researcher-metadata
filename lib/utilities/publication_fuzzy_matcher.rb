# frozen_string_literal: true

class PublicationFuzzyMatcher
  MATCH_THRESHOLD = 0.90

  def initialize(rmd_publication)
    @rmd_publication = rmd_publication
  end

  def match?(scholar_publication_title, scholar_publication_year = nil)
    score = calculate_match_score(scholar_publication_title, scholar_publication_year)
    score >= MATCH_THRESHOLD
  end

  def match_score(scholar_publication_title, scholar_publication_year = nil)
    calculate_match_score(scholar_publication_title, scholar_publication_year)
  end

  private

    def calculate_match_score(scholar_title, scholar_year)
      title_score = calculate_title_score(scholar_title)

      if scholar_year && @rmd_publication.published_on
        year_match = scholar_year == @rmd_publication.published_on.year ? 1.0 : 0.0
        (title_score + year_match) / 2.0
      else
        title_score
      end
    end

    def calculate_title_score(scholar_title)
      rmd_title = normalized_title(@rmd_publication.title)
      scholar_normalized = normalized_title(scholar_title)

      result = ActiveRecord::Base.connection.execute(
        'SELECT similarity($1, $2) AS score',
        [rmd_title, scholar_normalized]
      )

      result.first['score'].to_f
    rescue PG::Error => e
      Rails.logger.warn("Error calculating title similarity: #{e.message}")
      0.0
    end

    def normalized_title(title)
      title.to_s.downcase.gsub(/[^a-z0-9\s]/, '').strip
    end
end
