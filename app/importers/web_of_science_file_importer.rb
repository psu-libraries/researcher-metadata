require 'nokogiri'
require 'byebug'

class WebOfScienceFileImporter
  def initialize(dirname:)
    @dirname = dirname
  end

  def call
    import_files = Dir.children(dirname).select { |f| File.extname(f) == '.xml' }
    pbar = ProgressBar.create(title: 'Importing Web of Science Data', total: import_files.count) unless Rails.env.test?
    import_files.each do |file|
      Nokogiri::XML::Reader(File.open(dirname.join(file))).each do |node|
        if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          wos_pub = WebOfSciencePublication.new(Nokogiri::XML(node.outer_xml).at('REC'))
          if wos_pub.importable?

            existing_pubs = Publication.find_by_wos_pub(wos_pub)

            if existing_pubs.any?
              wos_pub.grants.each do |g|
                ActiveRecord::Base.transaction do
                  if g.wos_agency.present?
                    g.ids.each do |id|
                      unless Grant.find_by(wos_agency_name: g.wos_agency, wos_identifier: id)
                        grant = Grant.new
                        grant.wos_agency_name = g.wos_agency
                        grant.agency_name = g.agency
                        grant.wos_identifier = id
                        grant.save!

                        existing_pubs.each do |p|
                          fund = ResearchFund.new
                          fund.publication = p
                          fund.grant = grant
                          fund.save!
                        end
                      end
                    end
                  end
                end
              end
            else
              users = User.find_all_by_wos_pub(wos_pub)
              if users.any?
                ActiveRecord::Base.transaction do
                  p = Publication.new
                  p.title = wos_pub.title
                  p.publication_type = "Journal Article"
                  p.doi = "https://doi.org/#{wos_pub.doi}" if wos_pub.doi
                  p.issn = wos_pub.issn
                  p.abstract = wos_pub.abstract
                  p.journal_title = wos_pub.journal_title
                  p.issue = wos_pub.issue
                  p.volume = wos_pub.volume
                  p.page_range = wos_pub.page_range
                  p.publisher = wos_pub.publisher
                  p.published_on = wos_pub.publication_date
                  p.status = 'Published'
                  p.save!

                  pi = PublicationImport.new
                  pi.publication = p
                  pi.source = "Web of Science"
                  pi.source_identifier = wos_pub.wos_id
                  pi.save!

                  wos_pub.grants.each do |g|
                    if g.wos_agency.present?
                      g.ids.each do |id|
                        grant = Grant.find_by(wos_agency_name: g.wos_agency, wos_identifier: id) || Grant.new
                        if grant.new_record?
                          grant = Grant.new
                          grant.wos_agency_name = g.wos_agency
                          grant.agency_name = g.agency
                          grant.wos_identifier = id
                          grant.save!
                        end
                        fund = ResearchFund.new
                        fund.publication = p
                        fund.grant = grant
                        fund.save!
                      end
                    end
                  end

                  users.each_with_index do |u, i|
                    a = Authorship.new
                    a.user = u
                    a.publication = p
                    a.author_number = i + 1
                    unless User.find_confirmed_by_wos_pub(wos_pub).include?(u)
                      a.confirmed = false
                    end
                    a.save!
                  end

                  wos_pub.author_names.each_with_index do |an, i|
                    c = Contributor.new
                    c.publication = p
                    c.first_name = an.first_name || an.first_initial
                    c.middle_name = an.middle_name || an.middle_initial
                    c.last_name = an.last_name
                    c.position = i + 1
                    c.save!
                  end
                end
              end
            end

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
