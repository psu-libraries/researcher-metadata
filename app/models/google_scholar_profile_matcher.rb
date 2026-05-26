# frozen_string_literal: true

class GoogleScholarProfileMatcher
  DOI_MATCH_THRESHOLD = 2
  TITLE_MATCH_THRESHOLD = 2
  TITLE_SIMILARITY_THRESHOLD = 0.90

  MatchResult = Struct.new(:matched?, :strategy, :match_count, :message, keyword_init: true)

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def match
    doi_count = doi_match_count
    return matched_result(:doi, doi_count) if doi_count >= DOI_MATCH_THRESHOLD

    title_count = title_match_count
    return matched_result(:title, title_count) if title_count >= TITLE_MATCH_THRESHOLD

    MatchResult.new(
      matched?: false,
      strategy: nil,
      match_count: [doi_count, title_count].max,
      message: "no DOI or title match met the threshold for user #{user.id}"
    )
  end

  private

    attr_reader :user, :profile

    def matched_result(strategy, count)
      MatchResult.new(
        matched?: true,
        strategy: strategy,
        match_count: count,
        message: "matched user #{user.id} by #{count} Google Scholar publication #{strategy} matches"
      )
    end

    def doi_match_count
      candidate_dois = candidate_publications.filter_map { |publication| normalized_doi(publication[:doi]) }.uniq
      return 0 if candidate_dois.empty?

      user_dois = user.publications.where.not(doi: [nil, '']).pluck(:doi).filter_map { |doi| normalized_doi(doi) }.uniq
      (candidate_dois & user_dois).count
    end

    def title_match_count
      candidate_publications.count do |publication|
        title = publication[:title].to_s
        year = publication[:year]
        next false if title.blank?

        matching_user_publications(title, year).exists?
      end
    end

    def matching_user_publications(title, year)
      relation = user.publications.where(
        %{similarity(CONCAT(title, secondary_title), ?) >= ?},
        title,
        TITLE_SIMILARITY_THRESHOLD
      )

      return relation unless year

      relation.where(
        %{? BETWEEN EXTRACT(YEAR FROM published_on)-2 AND EXTRACT(YEAR FROM published_on)+2 OR published_on IS NULL},
        year
      )
    end

    def candidate_publications
      Array(profile[:publications] || profile['publications']).map do |publication|
        publication.respond_to?(:symbolize_keys) ? publication.symbolize_keys : publication
      end
    end

    def normalized_doi(value)
      value.to_s.downcase.match(%r{10\.\S+/\S+})&.[](0)&.delete_suffix('.')
    end
end
