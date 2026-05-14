# frozen_string_literal: true

module NIHGrantImporter
  SOURCE = 'NIH'

  def self.call
    pbar = Utilities::ProgressBarTTY.create(title: 'Importing NIH Projects Data', total: NIHProjects.count)
    NIHProjects.find_in_batches do |p|
      g = Grant.find_by(agency_name: p.agency_name, identifier: p.identifier) || Grant.new
      g.identifier = p.identifier
      g.title = p.title
      g.start_date = p.start_date
      g.end_date = p.end_date
      g.abstract = p.abstract
      g.amount_in_dollars = p.amount_in_dollars
      g.agency_name = p.agency_name
      g.import_source = SOURCE
      g.save!

      p.principal_investigators.each do |pi|
        u = User.find_by_nih_investigator(pi) # rubocop:disable Rails/DynamicFindBy
        if u && !ResearcherFund.find_by(user: u, grant: g)
          rf = ResearcherFund.new
          rf.user = u
          rf.grant = g
          rf.import_source = SOURCE
          rf.save!
        end
      end

      p.publications.each do |p|
        pubs = Publication.find_by_metadata(p) # rubocop:disable Rails/DynamicFindBy
        pubs.each do |rmd_pub|
          unless ResearchFund.find_by(publication: rmd_pub, grant: g)
            rf = ResearchFund.new
            rf.publication = rmd_pub
            rf.grant = g
            rf.import_source = SOURCE
            rf.save!
          end
        end
      rescue NIHProjectPublication::MissingMetadata
        next
      end

      pbar.increment
    end
    pbar.finish
  end
end
