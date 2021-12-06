# frozen_string_literal: true

class PublicationMergeOnDoiPolicy
  def initialize(publication1, publication2)
    @publication1 = publication1
    @publication2 = publication2
  end

  # merge! is meant to only be applied to publications that return true
  # when analyzed with PublicationMatchOnDoiPolicy's #ok_to_merge? method
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
        title: title,
        secondary_title: secondary_title,
        journal: journal,
        journal_title: journal.present? ? nil : select_value(:journal_title),
        publisher_name: journal.present? ? nil : either_value(:publisher_name),
        published_on: most_distant_value(:published_on),
        status: status,
        volume: select_value(:volume),
        issue: select_value(:issue),
        edition: select_value(:edition),
        page_range: longer_value(:page_range),
        url: either_value(:url),
        issn: issn,
        isbn: either_value(:isbn),
        publication_type: publication_type,
        abstract: longer_value(:abstract),
        authors_et_al: authors_et_al,
        total_scopus_citations: either_value(:total_scopus_citations)
      }
    end

    def most_distant_value(attribute)
      [publication1.send(attribute), publication2.send(attribute)].reject(&:blank?).min
    end

    def either_value(attribute)
      [publication1.send(attribute), publication2.send(attribute)].uniq.reject(&:blank?).sample
    end

    def select_value(attribute)
      [publication1.send(attribute), publication2.send(attribute)].uniq.reject(&:blank?).first
    end

    def longer_value(attribute)
      [publication1.send(attribute), publication2.send(attribute)].reject(&:blank?).max_by(&:length)
    end

    def title
      title1 = publication1.title
      title2 = publication2.title
      secondary_title1 = publication1.secondary_title
      secondary_title2 = publication2.secondary_title
      if publication1.pure_import_identifiers.present?
        if secondary_title1.present? &&
            title1&.downcase&.gsub(/[^a-z0-9]/, '')&.exclude?(secondary_title1&.downcase&.gsub(/[^a-z0-9]/, ''))
          return "#{title1}: #{secondary_title1}"
        else
          return title1
        end
      end

      if publication2.pure_import_identifiers.present?
        if secondary_title2.present? &&
            title2&.downcase&.gsub(/[^a-z0-9]/, '')&.exclude?(secondary_title2&.downcase&.gsub(/[^a-z0-9]/, ''))
          return "#{title2}: #{secondary_title2}"
        else
          return title2
        end
      end

      longer_value(:title)
    end

    def secondary_title
      secondary_title1 = publication1.secondary_title
      secondary_title2 = publication2.secondary_title
      if publication1.pure_import_identifiers.present? || publication2.pure_import_identifiers.present?
        return nil
      end

      if secondary_title1.present? &&
          title&.downcase&.gsub(/[^a-z0-9]/, '')&.exclude?(secondary_title1&.downcase&.gsub(/[^a-z0-9]/, ''))
        return secondary_title1
      end

      if secondary_title2.present? &&
          title&.downcase&.gsub(/[^a-z0-9]/, '')&.exclude?(secondary_title2&.downcase&.gsub(/[^a-z0-9]/, ''))
        return secondary_title2
      end

      nil
    end

    def journal
      select_value(:journal)
    end

    def status
      if [publication1.status, publication2.status].include?(Publication::PUBLISHED_STATUS)
        Publication::PUBLISHED_STATUS
      else
        Publication::IN_PRESS_STATUS
      end
    end

    def issn
      if publication1.issn.blank? && publication2.issn.blank?
        nil
      else
        [publication1.issn, publication2.issn]
          .reject(&:blank?)
          .min_by(&:length)
          .gsub(/[^0-9xX]/, '')[0..7]
          .insert(4, '-')
      end
    end

    def authors_et_al
      [publication1.authors_et_al, publication2.authors_et_al].include?(true) ? true : false
    end

    def publication_type
      if [publication1, publication2].map(&:publication_type_other?).count(true) == 1
        [publication1, publication2].reject(&:publication_type_other?).first.publication_type
      else
        longer_value(:publication_type)
      end
    end

    attr_reader :publication1, :publication2
end
