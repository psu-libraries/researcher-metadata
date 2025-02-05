# frozen_string_literal: true

class PurePublicationImporter < PureImporter
  IMPORT_SOURCE = 'Pure'

  def call
    pbar = Utilities::ProgressBarTTY.create(title: 'Importing Pure research-outputs (publications)', total: total_pages)

    import = Import.create!(source: 'Pure', started_at: Time.current)

    1.upto(total_pages) do |page|
      offset = (page - 1) * page_size
      pubs = get_records(type: record_type, page_size: page_size, offset: offset)

      pubs['items'].each do |publication|
        SourcePublication.create!(
          import: import,
          source_identifier: publication['uuid'],
          status: status_value(publication)
        )

        next unless importable?(publication)

        ActiveRecord::Base.transaction do
          # We will not do any error handling inside this transaction because I
          # don't want to affect the transaction rollback

          pi = PublicationImport.find_by(source: IMPORT_SOURCE,
                                         source_identifier: publication['uuid']) ||
            PublicationImport.new(source: IMPORT_SOURCE,
                                  source_identifier: publication['uuid'])

          p = pi.publication

          pi.source_updated_at = publication['info']['modifiedDate']

          if pi.persisted?
            if p.updated_by_user_at.present?
              attrs = {}
              attrs[:total_scopus_citations] = publication['totalScopusCitations']
              attrs[:journal] = journal_present?(publication) ? journal(publication) : nil
              if !p.published?
                attrs[:status] = status_value(publication)
              end
              attrs[:title] = title(publication)

              attrs = attrs.merge(doi: doi(publication)) if p.doi.blank?
              pi.publication.update!(attrs)
            else
              pi.publication.update!(pub_attrs(publication))
            end
          else
            p = Publication.create!(pub_attrs(publication))
            # Verify the DOI for new publications
            DOIVerificationJob.perform_later(p.id)
            pi.publication = p

            DuplicatePublicationGroup.group_duplicates_of(p)
            group = p.reload.duplicate_group
            if group
              other_pubs = group.publications.where.not(id: p.id)
              other_pubs.update_all(visible: false)
            end
          end

          pi.save!

          if p.updated_by_user_at.blank?
            p.contributor_names.delete_all

            authorships = publication['personAssociations'].select do |a|
              a['authorCollaboration'].blank? &&
                a['personRole']['term']['text'].find { |t| t['locale'] == 'en_US' }['value'] == 'Author'
            end

            authorships.each_with_index do |a, i|
              if a['person'].present?
                u = User.find_by(pure_uuid: a['person']['uuid'])

                if u
                  authorship = Authorship.find_by(user: u, publication: p) || Authorship.new

                  authorship.user = u if authorship.new_record?
                  authorship.publication = p if authorship.new_record?
                  authorship.author_number = i + 1
                  begin
                    authorship.save!
                  rescue ActiveRecord::RecordInvalid => e
                    @errors << e
                  end
                end
              end
              contributor_name_attrs = {
                publication: p,
                first_name: a['name']['firstName'],
                last_name: a['name']['lastName'],
                position: i + 1
              }
              contributor_name_attrs[:user] = u if u
              ContributorName.create!(contributor_name_attrs)
            end
          end
        end
      rescue StandardError => e
        log_error(e, { publication: publication })
      end
      pbar.increment
    rescue StandardError => e
      log_error(e, {})
    end

    import.update_column(:completed_at, Time.current)
    pbar.finish
  rescue StandardError => e
    log_error(e, {})
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
        title: title(publication),
        secondary_title: nil,
        publication_type: PurePublicationTypeMapIn.map(publication['type']['term']['text']
                                                  .find { |t| t['locale'] == 'en_US' }['value']),
        page_range: publication['pages'],
        volume: publication['volume'],
        issue: publication['journalNumber'],
        journal: journal_present?(publication) ? journal(publication) : nil,
        issn: journal_present?(publication) ? issn(publication) : nil,
        status: status_value(publication),
        published_on: Date.new(status(publication)['publicationDate']['year'].to_i,
                               published_month(publication),
                               published_day(publication)),
        total_scopus_citations: publication['totalScopusCitations'],
        abstract: abstract(publication),
        visible: true,
        doi: doi(publication)
      }
    end

    def title(publication)
      publication['title']['value'] + subtitle(publication)
    end

    def subtitle(publication)
      publication['subTitle'].try('[]', 'value').present? ? ": #{publication['subTitle'].try('[]', 'value')}" : ''
    end

    def issn(publication)
      publication['journalAssociation']['issn'].present? ? publication['journalAssociation']['issn']['value'] : nil
    end

    def status(publication)
      publication['publicationStatuses'].find { |s| s['current'] == true }
    end

    def status_value(publication)
      status(publication)['publicationStatus']['term']['text'].find { |t| t['locale'] == 'en_US' }['value']
    end

    def published_month(publication)
      status(publication)['publicationDate']['month'].present? ? status(publication)['publicationDate']['month'].to_i : 1
    end

    def published_day(publication)
      status(publication)['publicationDate']['day'].present? ? status(publication)['publicationDate']['day'].to_i : 1
    end

    def abstract(publication)
      if publication['abstract']
        publication['abstract']['text'].find { |t| t['locale'] == 'en_US' }['value']
      end
    end

    def doi(publication)
      if publication['electronicVersions']
        v = publication['electronicVersions'].find do |ev|
          if ev['versionType']
            ev['versionType']['term']['text'].find { |t| t['locale'] == 'en_US' }['value'] == 'Final published version'
          end
        end
        raw_doi = v.try('[]', 'doi')
        DOISanitizer.new(raw_doi).url
      end
    end

    def journal(publication)
      if publication['journalAssociation']['journal'].present?
        Journal.find_by(pure_uuid: publication['journalAssociation']['journal']['uuid'])
      end
    end

    def journal_present?(publication)
      publication['journalAssociation'].present?
    end

    def importable?(publication)
      status_value(publication) == 'Published' || status_value(publication) == 'Accepted/In press'
    end
end
