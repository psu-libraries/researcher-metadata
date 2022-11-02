# frozen_string_literal: true

class OAIImporter
  def call
    puts "Loading publication records from #{repo_url} ..." unless Rails.env.test?
    load_records
    pbar = ProgressBarTTY.create(title: 'Importing publications', total: repo_records.count)

    repo_records.each do |rr|
      pbar.increment

      if rr.any_user_matches?
        ActiveRecord::Base.transaction do
          pi = PublicationImport.find_by(source: import_source, source_identifier: rr.identifier) ||
            PublicationImport.new

          # For now we don't anticipate that source data that we've already imported
          # will change, so we only need to create new records, and we don't need to
          # update existing records.
          unless pi.persisted?
            p = Publication.new
            p.title = rr.title
            p.journal_title = rr.source
            p.abstract = rr.description
            p.published_on = rr.date
            p.publisher_name = rr.publisher
            p.publication_type = 'Journal Article'
            p.status = 'Published'
            p.save!

            pi.publication = p
            pi.source = import_source
            pi.source_identifier = rr.identifier
            pi.save!

            rr.creators.each_with_index do |c, i|
              con = ContributorName.new
              con.publication = p
              con.first_name = c.first_name
              con.last_name = c.last_name
              con.position = i + 1
              con.user = c.user_match if c.user_match
              con.save!

              if c.user_match
                a = Authorship.new
                a.publication = p
                a.user = c.user_match
                a.author_number = i + 1
                a.confirmed = true
                a.save!
              end

              c.ambiguous_user_matches.each do |aum|
                a = Authorship.new
                a.publication = p
                a.user = aum
                a.author_number = i + 1
                a.confirmed = false
                a.save!
              end
            end

            DuplicatePublicationGroup.group_duplicates_of(p)

            if p.reload.duplicate_group
              p.update!(visible: false)
            end
          end

          pub = pi.reload.publication

          if OpenAccessLocation.find_by(publication: pub, source: location_source).blank?
            oal = OpenAccessLocation.new
            oal.publication = pub
            oal.url = rr.url
            oal.source = location_source # TODO return to import_source once import sources are refactored
            oal.save!
          end
        end
      end
    end
    pbar.finish
    nil
  end

  private

    attr_reader :repo_records

    def repo_url
      raise NotImplementedError.new('This method should be defined in a subclass')
    end

    def import_source
      raise NotImplementedError.new('This method should be defined in a subclass')
    end

    # TODO this is a temporary method so we can refactor the sources used in
    # OpenAccessLocation and PublicationImport separately. Once botha are refactored
    # to use the Source object, then we should remove this method and only
    # use #import_source
    def location_source
      raise NotImplementedError.new('This method should be defined in a subclass')
    end

    def record_type
      raise NotImplementedError.new('This method should be defined in a subclass')
    end

    def set
      raise NotImplementedError.new('This method should be defined in a subclass')
    end

    def repo
      @repo ||= Fieldhand::Repository.new(repo_url)
    end

    def load_records
      @repo_records = []
      repo.records(metadata_prefix: 'dcs', set: set).each do |r|
        @repo_records.push record_type.new(r)
      end
    end
end
