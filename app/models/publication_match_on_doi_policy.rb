# frozen_string_literal: true

class PublicationMatchOnDOIPolicy
  def initialize(publication1, publication2)
    @publication1 = publication1
    @publication2 = publication2
  end

  # if ok_to_merge returns true, these publications can be merged by PublicationMergeOnMatchingPolicy
  def ok_to_merge?
    return true if doi_pass? &&
      title_pass? &&
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

    def title_pass?
      title1 = publication1.title.to_s + publication1.secondary_title.to_s
      title2 = publication2.title.to_s + publication2.secondary_title.to_s
      search = Publication.where(%{similarity(CONCAT(title, secondary_title), ?) >= 0.6}, "#{publication1.title}#{publication1.secondary_title}")
      one_value_present?(title1, title2) || search.include?(publication2)
    end

    def publication_type_pass?
      type1 = publication1.publication_type
      type2 = publication2.publication_type
      one_value_present?(type1, type2) ||
        (publication1.is_journal_publication? && publication2.is_journal_publication?) ||
        (publication1.publication_type_other? || publication2.publication_type_other?) ||
        (publication1.is_merge_allowed? && publication2.is_merge_allowed?) ||
        eql_values?(type1, type2)
    end

    attr_accessor :publication1, :publication2
end
