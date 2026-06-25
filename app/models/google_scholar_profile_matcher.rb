# frozen_string_literal: true

require 'utilities/google_scholar_url'

class GoogleScholarProfileMatcher
  include Utilities::GoogleScholarURL

  DOI_MATCH_THRESHOLD = 2
  DOI_MATCH_THRESHOLD_PSU = 1
  TITLE_MATCH_THRESHOLD = 2
  TITLE_MATCH_THRESHOLD_PSU = 1
  TITLE_SIMILARITY_THRESHOLD = 0.90
  PSU_EMAIL_DOMAINS = %w[psu.edu].freeze
  PSU_INSTITUTION_NAMES = ['Penn State', 'Pennsylvania State'].freeze

  MatchResult = Struct.new(:matched?, :strategy, :match_count, :message, keyword_init: true)

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def match
    affiliation_status = psu_affiliation_status

    if affiliation_status == :not_psu
      return MatchResult.new(
        matched?: false,
        strategy: :institution,
        match_count: 0,
        message: "rejected user #{user.id} — Scholar profile institution is not Penn State " \
                 "(#{profile[:email_domain]})"
      )
    end

    doi_threshold = affiliation_status == :psu ? DOI_MATCH_THRESHOLD_PSU : DOI_MATCH_THRESHOLD
    doi_count = doi_match_count
    return matched_result(:doi, doi_count) if doi_count >= doi_threshold

    title_threshold = affiliation_status == :psu ? TITLE_MATCH_THRESHOLD_PSU : TITLE_MATCH_THRESHOLD
    title_count = title_match_count
    return matched_result(:title, title_count) if title_count >= title_threshold

    MatchResult.new(
      matched?: false,
      strategy: nil,
      match_count: [doi_count, title_count].max,
      message: "no DOI or title match met the threshold for user #{user.id}"
    )
  end

  private

    attr_reader :user, :profile

    def psu_affiliation_status
      email_domain = profile[:email_domain].to_s.strip.downcase
      affiliation = profile[:affiliation].to_s

      if email_domain.present?
        return :psu if PSU_EMAIL_DOMAINS.any? { |d| email_domain == d || email_domain.end_with?(".#{d}") }

        return :not_psu
      end

      return :psu if PSU_INSTITUTION_NAMES.any? { |name| affiliation.include?(name) }

      :unknown
    end

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
      Array(profile[:publications])
    end
end
