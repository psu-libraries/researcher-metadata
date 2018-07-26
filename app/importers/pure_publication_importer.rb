class PurePublicationImporter
  # This importer is initialized with a path to a directory containing one or more JSON
  # files of exported "research-outputs" data from Pure
  # (https://pennstate.pure.elsevier.com/ws/api/510/api-docs/index.html#!/research45outputs/listResearchOutputs_2)
  # The directory is assumed to only contain files of this type, and the exports should be batched
  # such that none of the files are larger than around 20 MB for efficient parsing/importing.

  attr_reader :errors

  def initialize(dirname:)
    @dirname = dirname
    @errors = []
  end

  def call
    import_files = Dir.children(dirname)
    pbar = ProgressBar.create(title: 'Importing Pure Publications', total: import_files.count) unless Rails.env.test?
    import_files.each do |filename|
      File.open(dirname + '/' + filename, 'r') do |file|
        MultiJson.load(file)['items'].each do |publication|
          if publication['type'].detect { |t| t['value'] == 'Article' }
            unless PublicationImport.find_by(import_source: "Pure", source_identifier: publication['uuid'])
              status = publication['publicationStatuses'].detect { |s| s['current'] == true }
              ActiveRecord::Base.transaction do
                published_month = status['publicationDate']['month'].present? ? status['publicationDate']['month'].to_i : 1
                published_day = status['publicationDate']['day'].present? ? status['publicationDate']['day'].to_i : 1
                issn = publication['journalAssociation']['issn'].present? ? publication['journalAssociation']['issn']['value'] : nil

                p = Publication.create!({
                  title: publication['title'],
                  secondary_title: publication['subTitle'],
                  publication_type: "Academic Journal Article",
                  page_range: publication['pages'],
                  volume: publication['volume'],
                  issue: publication['journalNumber'],
                  journal_title: publication['journalAssociation']['title']['value'],
                  issn: issn,
                  status: status['publicationStatus'][0]['value'],
                  published_on: Date.new(status['publicationDate']['year'].to_i,
                                           published_month,
                                           published_day),
                  citation_count: publication['totalScopusCitations']})

                pi = PublicationImport.new
                pi.publication = p
                pi.import_source = "Pure"
                pi.source_identifier = publication['uuid']
                pi.title = publication['title']
                pi.secondary_title = publication['subTitle']
                pi.publication_type = "Academic Journal Article"
                pi.source_updated_at = publication['info']['modifiedDate']
                pi.page_range = publication['pages']
                pi.volume = publication['volume']
                pi.issue = publication['journalNumber']
                pi.journal_title = publication['journalAssociation']['title']['value']
                pi.issn = issn
                pi.status = status['publicationStatus'][0]['value']
                pi.published_on = Date.new(status['publicationDate']['year'].to_i,
                                           published_month,
                                           published_day.to_i)
                pi.confidential = publication['confidential']
                pi.citation_count = publication['totalScopusCitations']
                pi.save!

                authorships = publication['personAssociations'].select { |a| !a['authorCollaboration'].present? &&

                  ra['personRole'].detect { |r| r['value'] == 'Author' }.present? }
                authorships.each_with_index do |a, i|
                  if a['person'].present?
                    u = User.find_by(pure_uuid: a['person']['uuid'])
                    unless Authorship.find_by(pure_identifier: a['pureId'])
                      begin
                        Authorship.create!(user: u,
                                           publication: p,
                                           author_number: i+1,
                                           pure_identifier: a['pureId'])
                      rescue ActiveRecord::RecordInvalid => e
                        @errors << e
                      end
                    end
                  end

                  unless ContributorImport.find_by(import_source: 'Pure', source_identifier: a['pureId'])
                    ci = ContributorImport.new
                    ci.publication_import = pi
                    ci.first_name = a['name']['firstName']
                    ci.last_name = a['name']['lastName']
                    ci.import_source = 'Pure'
                    ci.source_identifier = a['pureId']
                    ci.position = i+1
                    ci.save!

                    c = Contributor.new
                    c.publication = pi.publication
                    c.first_name = a['name']['firstName']
                    c.last_name = a['name']['lastName']
                    c.position = i+1
                    c.save!
                  end
                end

                nil
              end
            end
          end
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
    nil
  end

  private

  attr_reader :dirname
end