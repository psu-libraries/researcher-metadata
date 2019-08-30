require 'nokogiri'
require 'byebug'

class WebOfScienceFileImporter
  def call
    Nokogiri::XML::Reader(File.open('/Volumes/WA_ext_HD/web_of_science_data/CORE_2013-2018/2013_CORE/WR_2013_20190215154350_CORE_0022.xml')).each do |node|
      if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        pub = WebOfSciencePublication.new(Nokogiri::XML(node.outer_xml).at('REC'))

        if pub.importable?
          pub.author_names.each do |n|
            user = User.find_by(first_name: n.first_name, last_name: n.last_name)

            if user
              puts "USER:  #{user.name}\n"
              puts "TITLE:  #{pub.title}"
              puts "DOI:  #{pub.doi}"
              puts "JOURNAL TITLE:  #{pub.journal_title}"
              puts "ISSUE:  #{pub.issue}"
              puts "VOLUME:  #{pub.volume}"
              puts "PAGES:  #{pub.page_range}"
              puts "PUBLISHED ON:  #{pub.publication_date}"

              puts "\n"
              puts "NAMES:"
              pub.author_names.each do |n|
                puts "#{n.first_name || n.first_initial} #{n.last_name}"
              end
              puts "\n"

              puts "ABSTRACT:"
              puts pub.abstract
              puts "\n"

              puts "CONTRIBUTORS:"
              pub.contributors.each do |c|
                puts "#{c.name.first_name || c.name.first_initial} #{c.name.last_name}"
                puts c.orcid
                puts "\n"
              end

              puts "GRANTS:"
              pub.grants.each do |g|
                puts g.agency
                g.ids.each do |id|
                  puts id
                end
                puts "\n"
              end

              puts "\n-------------------------------------------\n"
            end
          end
        end
      end
    end
  end
end
