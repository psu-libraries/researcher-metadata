class PurePublicationImporter < PureImporter
  IMPORT_SOURCE = 'Pure'

  def call
    pbar = ProgressBar.create(title: 'Importing Pure research-outputs (publications)', total: total_pages) unless Rails.env.test?

    1.upto(total_pages) do |i|
      offset = (i-1) * page_size
      pubs = get_records(type: record_type, page_size: page_size, offset: offset)

      pubs['items'].each do |publication|

        ActiveRecord::Base.transaction do
          pi = PublicationImport.find_by(source: IMPORT_SOURCE,
                                          source_identifier: publication['uuid']) ||
            PublicationImport.new(source: IMPORT_SOURCE,
                                  source_identifier: publication['uuid'])

          p = pi.publication

          pi.source_updated_at = publication['info']['modifiedDate']

          if pi.persisted?
            if p.updated_by_user_at.present?
              attrs = {
                total_scopus_citations: publication['totalScopusCitations'],
                journal: journal_present?(publication) ? journal(publication) : nil
              }
              attrs = attrs.merge(doi: doi(publication)) unless p.doi.present?
              pi.publication.update_attributes!(attrs)
            else
              pi.publication.update_attributes!(pub_attrs(publication))
            end
          else
            p = Publication.create!(pub_attrs(publication))
            pi.publication = p

            DuplicatePublicationGroup.group_duplicates_of(p)
            group = p.reload.duplicate_group
            if group
              other_pubs = group.publications.where.not(id: p.id)
              other_pubs.update_all(visible: false)
            end
          end

          pi.save!

          unless p.updated_by_user_at.present?
            p.contributor_names.delete_all

            authorships = publication['personAssociations'].select do |a|
              !a['authorCollaboration'].present? &&
                a['personRole']['term']['text'].detect { |t| t['locale'] == 'en_US' }['value'] == 'Author'
            end

            authorships.each_with_index do |a, i|
              if a['person'].present?
                u = User.find_by(pure_uuid: a['person']['uuid'])

                if u
                  authorship = Authorship.find_by(user: u, publication: p) || Authorship.new

                  authorship.user = u if authorship.new_record?
                  authorship.publication = p if authorship.new_record?
                  authorship.author_number = i+1
                  begin
                    authorship.save!
                  rescue ActiveRecord::RecordInvalid => e
                    @errors << e
                  end
                end
              end
              ContributorName.create!(publication: p,
                                      first_name: a['name']['firstName'],
                                      last_name: a['name']['lastName'],
                                      position: i+1)
            end
          end
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  def page_size
    500
  end

  def record_type
    'research-outputs'
  end

  private

  def pub_attrs(publication)
    {
      title: publication['title']['value'],
      secondary_title: publication['subTitle'].try('[]', 'value'),
      publication_type: PurePublicationTypeMapIn.map(publication['type']['term']['text']
                                                .detect { |t| t['locale'] == 'en_US' }['value']),
      page_range: publication['pages'],
      volume: publication['volume'],
      issue: publication['journalNumber'],
      journal: journal_present?(publication) ? journal(publication) : nil,
      issn: journal_present?(publication) ? issn(publication) : nil,
      status: status(publication)['publicationStatus']['term']['text'].detect { |t| t['locale'] == 'en_US'}['value'],
      published_on: Date.new(status(publication)['publicationDate']['year'].to_i,
                             published_month(publication),
                             published_day(publication)),
      total_scopus_citations: publication['totalScopusCitations'],
      abstract: abstract(publication),
      visible: true,
      doi: doi(publication)
    }
  end

  def issn(publication)
    publication['journalAssociation']['issn'].present? ? publication['journalAssociation']['issn']['value'] : nil
  end

  def status(publication)
    publication['publicationStatuses'].detect { |s| s['current'] == true }
  end

  def published_month(publication)
    status(publication)['publicationDate']['month'].present? ? status(publication)['publicationDate']['month'].to_i : 1
  end

  def published_day(publication)
    status(publication)['publicationDate']['day'].present? ? status(publication)['publicationDate']['day'].to_i : 1
  end

  def abstract(publication)
    if publication['abstract']
      publication['abstract']['text'].detect { |t| t['locale'] == 'en_US'}['value']
    end
  end

  def doi(publication)
    if publication['electronicVersions']
      v = publication['electronicVersions'].detect do |ev|
        if ev['versionType']
          ev['versionType']['term']['text'].detect { |t| t['locale'] == 'en_US' }['value'] == "Final published version"
        end
      end
      v.try('[]', 'doi')
    end
  end

  def journal(publication)
    publication['journalAssociation']['journal'].present? ?
        Journal.find_by(pure_uuid: publication['journalAssociation']['journal']['uuid']) : nil
  end

  def journal_present?(publication)
    publication['journalAssociation'].present?
  end
end
