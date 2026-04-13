# frozen_string_literal: true

class NSFGrantImporter
  def call
    (1965..Date.current.year).each do |year|
      # This request only returns the first 3000 matching awards, which is the maximum number
      # that the API will return at one time. However, since we're filtering for only Penn State
      # related awards and we're only requesting one year at a time, the results never contain
      # more than a few hundred awards.
      query_url = "https://api.nsf.gov/services/v1/awards.json?dateStart=01%2F01%2F#{year}&dateEnd=12%2F31%2F#{year}&rpp=3000&offset=0&awardeeName=%22Pennsylvania+State+Univ%22"
      response = HTTParty.get(query_url)
      awards = NSFAwards.new(response.body)
      pbar = Utilities::ProgressBarTTY.create(title: "Importing NSF Awards Data from #{year}", total: awards.count)
      awards.each do |a|
        g = Grant.find_by(agency_name: a.agency_name, identifier: a.identifier) || Grant.new
        g.identifier = a.identifier
        g.title = a.title
        g.start_date = a.start_date
        g.end_date = a.end_date
        g.abstract = a.abstract
        g.amount_in_dollars = a.amount_in_dollars
        g.agency_name = a.agency_name
        g.save!
        pbar.increment

        user = User.find_by_nsf_grant(a)
        if user && !ResearcherFund.find_by(user: user, grant: g)
          rf = ResearcherFund.new
          rf.user = user
          rf.grant = g
          rf.save!
        end

        a.publications.each do |pub_from_nsf|
          pubs = Publication.find_by_metadata(pub_from_nsf)
          pubs.each do |rmd_pub|
            unless ResearchFund.find_by(publication: rmd_pub, grant: g)
              rf = ResearchFund.new
              rf.publication = rmd_pub
              rf.grant = g
              rf.save!
            end
          end
        end
      end
      pbar.finish
    end
  end
end
