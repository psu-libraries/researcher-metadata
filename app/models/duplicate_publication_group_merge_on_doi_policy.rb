# frozen_string_literal: true

class DuplicatePublicationGroupMergeOnDoiPolicy
  def initialize(publication1, publication2)
    @publication1 = publication1
    @publication2 = publication2
  end

  def ok_to_merge?
    return true if dois_eql? &&
                   standard_pass?(:title) &&
                   standard_pass?(:secondary_title) &&
                   journal_pass? &&
                   publisher_pass? &&
                   standard_pass?(:published_on) &&
                   standard_pass?(:volume) &&
                   standard_pass?(:issue) &&
                   standard_pass?(:edition) &&
                   page_range_pass? &&
                   issn_pass? &&
                   publication_type_pass?

    false
  end

  def merge!
    publication1.update! attributes
  end

  private

  def attributes
    {
      title: [publication1.title, publication2.title].uniq.compact.first,
      secondary_title: [publication1.secondary_title, publication2.secondary_title].uniq.compact.first,
      journal: [publication1.journal, publication2.journal].uniq.compact.first,
      publisher: [publication1.publisher, publication2.publisher].uniq.compact.first,
      published_on: [publication1.published_on, publication2.published_on].uniq.compact.first,
      status: [publication1.status, publication2.status].include?(Publication::PUBLISHED_STATUS) ?
                                                                      Publication::PUBLISHED_STATUS :
                                                                      Publication::IN_PRESS_STATUS,
      volume: [publication1.volume, publication2.volume].uniq.compact.first,
      issue: [publication1.issue, publication2.issue].uniq.compact.first,
      edition: [publication1.edition, publication2.edition].uniq.compact.first,
      page_range: [publication1.page_range, publication2.page_range].compact.max_by(&:length),
      issn: [publication1.issn, publication2.issn].compact.max_by(&:length),
      publication_type: [publication1.publication_type, publication2.publication_type].compact.max_by(&:length)
    }
  end

  def one_value_present?(value1, value2)
    return true if [value1, value2].reject(&:blank?).count == 1

    false
  end

  def eql_values?(string1, string2)
    string1.to_s.downcase.strip == string2.to_s.downcase.strip
  end

  def dois_eql?
    publication1.doi == publication2.doi
  end

  def standard_pass?(attribute)
    pub1_value = publication1.send(attribute)
    pub2_value = publication2.send(attribute)
    one_value_present?(pub1_value, pub2_value) || eql_values?(pub1_value, pub2_value)
  end

  def journal_pass?
    journal1 = publication1.journal
    journal2 = publication2.journal
    one_value_present?(journal1, journal2) || eql_values?(journal1.title, journal2.title)
  end

  def publisher_pass?
    publisher1 = publication1.publisher
    publisher2 = publication2.publisher
    one_value_present?(publisher1, publisher2) || eql_values?(publisher1.name, publisher2.name)
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