# frozen_string_literal: true

class PublicationMergeOnDoiPolicy
  def initialize(publication1, publication2)
    @publication1 = publication1
    @publication2 = publication2
  end

  def ok_to_merge?
    return true if doi_pass? &&
                   title_pass?(:title) &&
                   title_pass?(:secondary_title) &&
                   journal_pass? &&
                   standard_pass?(:volume) &&
                   standard_pass?(:issue) &&
                   standard_pass?(:edition) &&
                   page_range_pass? &&
                   issn_pass? &&
                   publication_type_pass?

    false
  end

  def merge!
    publication1.update attributes
    publication1.contributor_names = contributor_names_to_keep
    publication1.save!
  end

  private

  def contributor_names_to_keep
    ContributorNameMergePolicy.new([publication1.contributor_names,
                                    publication2.contributor_names].flatten).contributor_names_to_keep
  end

  def attributes
    {
      title: longer_value(:title),
      secondary_title: longer_value(:secondary_title),
      journal: select_value(:journal),
      journal_title: select_value(:journal_title),
      publisher_name: either_value(:publisher_name),
      published_on: most_recent_value(:published_on),
      status: [publication1.status, publication2.status].include?(Publication::PUBLISHED_STATUS) ?
                                                                      Publication::PUBLISHED_STATUS :
                                                                      Publication::IN_PRESS_STATUS,
      volume: select_value(:volume),
      issue: select_value(:issue),
      edition: select_value(:edition),
      page_range: longer_value(:page_range),
      url: either_value(:url),
      issn: longer_value(:issn),
      isbn: either_value(:isbn),
      publication_type: longer_value(:publication_type),
      abstract: longer_value(:abstract),
      author_et_al: [publication1.authors_et_al, publication2.authors_et_al].include?(true) ? true : false,
      total_scopus_citations: either_value(:total_scopus_citations)
    }
  end

  def most_recent_value(attribute)
    [publication1.send(attribute), publication2.send(attribute)].compact.sort.last
  end

  def either_value(attribute)
    [publication1.send(attribute), publication2.send(attribute)].uniq.compact.sample
  end

  def select_value(attribute)
    [publication1.send(attribute), publication2.send(attribute)].uniq.compact.first
  end

  def longer_value(attribute)
    [publication1.send(attribute), publication2.send(attribute)].compact.max_by(&:length)
  end

  def one_value_present?(value1, value2)
    return true if [value1, value2].reject(&:blank?).count == 1

    false
  end

  def eql_values?(string1, string2)
    string1.to_s.downcase.strip == string2.to_s.downcase.strip
  end

  def doi_pass?
    return false unless publication1.doi.present? && publication2.doi.present?

    publication1.doi == publication2.doi
  end

  def standard_pass?(attribute)
    pub1_value = publication1.send(attribute)
    pub2_value = publication2.send(attribute)
    one_value_present?(pub1_value, pub2_value) || eql_values?(pub1_value, pub2_value)
  end

  def title_pass?(title_attr)
    title1 = publication1.send(title_attr)
    title2 = publication2.send(title_attr)
    one_value_present?(title1, title2) || (title1&.downcase&.gsub(/[^a-z0-9]/, '') == title2&.downcase&.gsub(/[^a-z0-9]/, ''))
  end

  def journal_pass?
    journal1 = publication1.journal.present? ? publication1.journal.title : publication1.journal_title
    journal2 = publication2.journal.present? ? publication2.journal.title : publication2.journal_title
    one_value_present?(journal1, journal2) || eql_values?(journal1, journal2)
  end

  def page_range_pass?
    pages1 = publication1.page_range
    pages2 = publication2.page_range
    one_value_present?(pages1, pages2) || (pages1&.split('-')&.first == pages2&.split('-')&.first)
  end

  def issn_pass?
    issn1 = publication1.issn
    issn2 = publication2.issn
    one_value_present?(issn1, issn2) || (issn1&.gsub('-', '') == issn2&.gsub('-', ''))
  end

  def publication_type_pass?
    one_value_present?(publication1.publication_type, publication2.publication_type) ||
        (publication1.is_journal_article? && publication1.is_journal_article?) ||
        eql_values?(publication1.publication_type, publication2.publication_type)
  end

  attr_reader :publication1, :publication2
end