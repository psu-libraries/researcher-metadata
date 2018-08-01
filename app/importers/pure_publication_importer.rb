class PurePublicationImporter
  # This importer is initialized with a path to a directory containing one or more JSON
  # files of exported "research-outputs" data from Pure
  # (https://pennstate.pure.elsevier.com/ws/api/511/api-docs/index.html#!/research45outputs/listResearchOutputs_2)
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
      File.open(dirname.join(filename), 'r') do |file|
        MultiJson.load(file)['items'].each do |publication|
          if publication['type'].detect { |t| t['value'] == 'Article' }
            issn = publication['journalAssociation']['issn'].present? ? publication['journalAssociation']['issn']['value'] : nil
            status = publication['publicationStatuses'].detect { |s| s['current'] == true }
            published_month = status['publicationDate']['month'].present? ? status['publicationDate']['month'].to_i : 1
            published_day = status['publicationDate']['day'].present? ? status['publicationDate']['day'].to_i : 1

            ActiveRecord::Base.transaction do
              p = Publication.find_by(pure_uuid: publication['uuid']) || Publication.new

              p.pure_uuid = publication['uuid'] if p.new_record?
              p.title = publication['title']
              p.secondary_title = publication['subTitle']
              p.publication_type = "Academic Journal Article" if p.new_record?
              p.pure_updated_at = publication['info']['modifiedDate']
              p.page_range = publication['pages']
              p.volume = publication['volume']
              p.issue = publication['journalNumber']
              p.journal_title = publication['journalAssociation']['title']['value']
              p.issn = issn
              p.status = status['publicationStatus'][0]['value']
              p.published_on = Date.new(status['publicationDate']['year'].to_i,
                                         published_month,
                                         published_day.to_i)
              p.citation_count = publication['totalScopusCitations']
              p.save!

              authorships = publication['personAssociations'].select { |a| !a['authorCollaboration'].present? &&
                a['personRole'].detect { |r| r['value'] == 'Author' }.present? }

              authorships.each_with_index do |a, i|
                if a['person'].present?
                  u = User.find_by(pure_uuid: a['person']['uuid'])

                  if u # Depends on users being imported from Pure first
                    authorship = Authorship.find_by(user: u, publication: p) || Authorship.new

                    authorship.user = u if authorship.new_record?
                    authorship.publication = p if authorship.new_record?
                    authorship.author_number = i+1
                    authorship.pure_identifier = a['pureId']
                    begin
                      authorship.save!
                    rescue ActiveRecord::RecordInvalid => e
                      @errors << e
                    end
                  end
                end

                c = Contributor.find_by(pure_identifier: a['pureId']) || Contributor.new
                c.publication = p
                c.first_name = a['name']['firstName']
                c.last_name = a['name']['lastName']
                c.position = i+1
                c.pure_identifier = a['pureId'] if c.new_record?
                c.save!
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
