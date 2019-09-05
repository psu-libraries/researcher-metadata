require 'nokogiri'
require 'byebug'

class WebOfScienceFileImporter
  def initialize(filename:)
    @filename = filename
  end

  def call
    Nokogiri::XML::Reader(File.open(filename)).each do |node|
      if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        wos_pub = WebOfSciencePublication.new(Nokogiri::XML(node.outer_xml).at('REC'))
        if wos_pub.importable?

          existing_pubs = Publication.find_by_wos_pub(wos_pub)

          if existing_pubs.any?
            wos_pub.grants.each do |g|
              ActiveRecord::Base.transaction do
                if g.agency.present?
                  g.ids.each do |id|
                    unless Grant.find_by(agency_name: g.agency, identifier: id)
                      grant = Grant.new
                      grant.agency_name = g.agency
                      grant.identifier = id
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
            users = User.find_by_wos_pub(wos_pub)
            if users.any?
              ActiveRecord::Base.transaction do
                p = Publication.new
                p.title = wos_pub.title
                p.publication_type = "Journal Article"
                p.save!

                pi = PublicationImport.new
                pi.publication = p
                pi.source = "Web of Science"
                pi.source_identifier = wos_pub.wos_id
                pi.save!

                wos_pub.grants.each do |g|
                  if g.agency.present?
                    g.ids.each do |id|
                      grant = Grant.find_by(agency_name: g.agency, identifier: id) || Grant.new
                      if grant.new_record?
                        grant = Grant.new
                        grant.agency_name = g.agency
                        grant.identifier = id
                        grant.save!
                      end
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

        end
      end
    end
  end

  private

  attr_reader :filename
end
