# frozen_string_literal: true

class OrcidWork < OrcidResource
  def to_json(*_args)
    work = {
      title: {
        title: publication.title,
        subtitle: publication.secondary_title
      },
      "journal-title": publication.preferred_journal_title,
      "short-description": publication.abstract,
      type: publication_type
    }

    if published_date.present?
      work[:"publication-date"] = {
        year: published_date.year,
        month: published_date.month,
        day: published_date.day
      }
    end

    if external_url.present?
      work[:"external-ids"] = { "external-id": [] } if work[:"external-ids"].blank?
      work[:"external-ids"][:"external-id"] << {
        "external-id-type": 'uri',
        "external-id-value": external_url.to_s,
        "external-id-relationship": 'self'
      }
    end

    if doi.present?
      work[:"external-ids"] = { "external-id": [] } if work[:"external-ids"].blank?
      work[:"external-ids"][:"external-id"] << {
        "external-id-type": 'doi',
        "external-id-value": doi,
        "external-id-relationship": 'self'
      }
    end

    contributors.each do |ext_author|
      middle_name = ext_author.middle_name.present? ? " #{ext_author.middle_name}" : ''
      work[:contributors] = { contributor: [] } if work[:contributors].blank?
      work[:contributors][:contributor] << {
        "credit-name": ext_author.first_name.to_s + middle_name + " #{ext_author.last_name}"
      }
    end

    work.to_json
  end

  def orcid_type
    'work'
  end

  def publication
    authorship.publication
  end

  def authorship
    model
  end

  private

    def external_url
      publication.preferred_open_access_url || publication.url
    end

    def doi
      publication.doi_url_path
    end

    def contributors
      publication.contributor_names
    end

    def published_date
      publication.published_on
    end

    def publication_type
      OrcidPublicationTypeMapOut.map(publication.publication_type)
    end
end
