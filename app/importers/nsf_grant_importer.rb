require 'nokogiri'

class NSFGrantImporter
  def initialize(dirname:)
    @dirname = dirname
  end

  def call
    import_files = Dir.children(dirname).select { |f| File.extname(f) == '.xml' }
    pbar = ProgressBar.create(title: 'Importing NSF Grant Data', total: import_files.count) unless Rails.env.test?
    import_files.each do |file|
      nsf_grant = NSFGrant.new(File.open(dirname.join(file)) { |f| Nokogiri::XML(f) })

      if nsf_grant.importable?
        g = Grant.find_by(agency_name: nsf_grant.agency_name, identifier: nsf_grant.identifier) || Grant.new
        g.identifier = nsf_grant.identifier
        g.title = nsf_grant.title
        g.start_date = nsf_grant.start_date
        g.end_date = nsf_grant.end_date
        g.abstract = nsf_grant.abstract
        g.amount_in_dollars = nsf_grant.amount_in_dollars
        g.agency_name = nsf_grant.agency_name
        g.save!

        users = User.find_by_nsf_grant(nsf_grant)
        users.each do |u|
          unless ResearcherFund.find_by(user: u, grant: g)
            rf = ResearcherFund.new
            rf.user = u
            rf.grant = g
            rf.save!
          end
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  private

  attr_reader :dirname
end
