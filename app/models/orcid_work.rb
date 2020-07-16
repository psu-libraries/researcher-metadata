class OrcidWork < OrcidResource
  def to_json
    external_ids = %i[isbn issn doi]

    work = {
      title: {
        title: publication.title,
        subtitle: publication.secondary_title,
      },
      "journal-title": publication.journal_title,
      "short-description": publication.abstract,
      type: 'journal-article',
      "publication-date": {
        year: publication.published_on.year,
        month: publication.published_on.month,
        day: publication.published_on.day
      },
      url: publication.url
    }

    external_ids.each do |type|
      if publication.send(type).present?
        relationship = (type == :doi ? 'self' : 'part-of')
        work[:"external-ids"] = { "external-id": [] } unless work[:"external-ids"].present?
        work[:"external-ids"][:"external-id"] << {
              "external-id-type": type.to_s,
              "external-id-value": publication.send(type).to_s,
              "external-id-relationship": relationship
        }
      end
    end

    publication.authorships.each do |ext_author|
      next if ext_author.user.id == user.id || ext_author.user.authenticated_orcid_identifier.blank?

      work[:contributors] = { contributor: [] } unless work[:contributors].present?
      work[:contributors][:contributor] << {
          "contributor-orcid": {
            path: ext_author.user.authenticated_orcid_identifier
          },
          "credit-name": "#{ext_author.user.first_name} #{ext_author.user.middle_name} #{ext_author.user.last_name}"
      }
    end

    work.to_json
  end

  def orcid_type
    "work"
  end

  def publication
    authorship.publication
  end

  def authorship
    model
  end
end