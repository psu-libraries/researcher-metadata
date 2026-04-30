# frozen_string_literal: true

require 'nokogiri'

class WebOfScienceFileImporter
  def initialize(dirname:)
    @dirname = dirname
  end

  def call
    import_files = Dir.children(dirname).select { |f| File.extname(f) == '.xml' }
    pbar = Utilities::ProgressBarTTY.create(title: 'Importing Web of Science Data', total: import_files.count)
    import_files.each do |file|
      Nokogiri::XML::Reader(File.open(dirname.join(file))).each do |node|
        if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          wos_pub = WebOfSciencePublication.new(Nokogiri::XML(node.outer_xml).at('REC'))
          if wos_pub.importable?

            existing_pubs = Publication.find_by_metadata(wos_pub)

            unless existing_pubs.any?
              users = User.find_all_by_wos_pub(wos_pub)
              if users.any?
                ActiveRecord::Base.transaction do
                  p = Publication.new
                  p.title = wos_pub.title
                  p.publication_type = 'Journal Article'
                  p.doi = wos_pub.doi
                  p.issn = wos_pub.issn
                  p.abstract = wos_pub.abstract
                  p.journal_title = wos_pub.journal_title
                  p.issue = wos_pub.issue
                  p.volume = wos_pub.volume
                  p.page_range = wos_pub.page_range
                  p.publisher_name = wos_pub.publisher
                  p.published_on = wos_pub.publication_date
                  p.status = 'Published'
                  p.save!

                  pi = PublicationImport.new
                  pi.publication = p
                  pi.source = 'Web of Science'
                  pi.source_identifier = wos_pub.wos_id
                  pi.save!

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
                    c = ContributorName.new
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
      pbar.increment
    end
    pbar.finish
  end

  private

    attr_reader :dirname
end
