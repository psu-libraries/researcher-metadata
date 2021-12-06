# frozen_string_literal: true

class PublicationMatchOnDoiPolicy
  def initialize(publication1, publication2)
    @publication1 = publication1
    @publication2 = publication2
  end

  # if ok_to_merge returns true, these publications can be merged by PublicationMergeOnDoiPolicy
  def ok_to_merge?
    return true if doi_pass? &&
      title_pass? &&
      journal_pass? &&
      standard_pass?(:volume) &&
      standard_pass?(:issue) &&
      standard_pass?(:edition) &&
      page_range_pass? &&
      issn_pass? &&
      publication_type_pass?

    false
  end

  private

    def one_value_present?(value1, value2)
      return true if [value1, value2].reject(&:blank?).count == 1

      false
    end

    def eql_values?(string1, string2)
      string1.to_s.downcase.strip == string2.to_s.downcase.strip
    end

    def doi_pass?
      return false unless publication1.doi.present? && publication2.doi.present?

      publication1.doi.casecmp(publication2.doi).zero?
    end

    def standard_pass?(attribute)
      pub1_value = publication1.send(attribute)
      pub2_value = publication2.send(attribute)
      one_value_present?(pub1_value, pub2_value) || eql_values?(pub1_value, pub2_value)
    end

    def title_pass?
      title1 = publication1.title.to_s + publication1.secondary_title.to_s
      title2 = publication2.title.to_s + publication2.secondary_title.to_s
      one_value_present?(title1, title2) ||
        title1&.downcase&.gsub(/[^a-z0-9]/, '')&.include?(title2&.downcase&.gsub(/[^a-z0-9]/, '')) ||
        title2&.downcase&.gsub(/[^a-z0-9]/, '')&.include?(title1&.downcase&.gsub(/[^a-z0-9]/, ''))
    end

    def journal_pass?
      journal1 = publication1.journal.present? ? publication1.journal.title&.gsub('&', 'and')&.gsub(',', '') : publication1.journal_title&.gsub('&', 'and')&.gsub(',', '')
      journal2 = publication2.journal.present? ? publication2.journal.title&.gsub('&', 'and')&.gsub(',', '') : publication2.journal_title&.gsub('&', 'and')&.gsub(',', '')
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
      one_value_present?(issn1, issn2) ||
        (issn1.blank? && issn2.blank?) ||
        issn1&.gsub(/[^0-9xX]/, '')&.include?(issn2&.gsub(/[^0-9xX]/, '')) ||
        issn2&.gsub(/[^0-9xX]/, '')&.include?(issn1&.gsub(/[^0-9xX]/, ''))
    end

    def publication_type_pass?
      type1 = publication1.publication_type
      type2 = publication2.publication_type
      one_value_present?(type1, type2) ||
        (publication1.is_journal_article? && publication2.is_journal_article?) ||
        (publication1.publication_type_other? || publication2.publication_type_other?) ||
        eql_values?(type1, type2)
    end

    attr_accessor :publication1, :publication2
end
