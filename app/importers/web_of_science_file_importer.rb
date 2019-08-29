require 'nokogiri'
require 'byebug'

class WebOfScienceFileImporter
  def call
    Nokogiri::XML::Reader(File.open('/Volumes/WA_ext_HD/web_of_science_data/CORE_2013-2018/2013_CORE/WR_2013_20190215154350_CORE_0022.xml')).each do |node|
      if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        rec = Nokogiri::XML(node.outer_xml).at('REC')
        pub = WebOfSciencePublication.new(rec)

        if pub.importable?
          rec.css('summary > names > name[role="author"]').each do |n|
            user = User.find_by(first_name: n.css('first_name').text.split(' ').first, last_name: n.css('last_name').text)

            if user
              puts "USER:  #{user.name}"

              puts "TITLE:\n"
              puts pub.title
              puts "\n"

              puts "DOI:\n"
              puts pub.doi
              puts "\n"

              puts "NAMES:\n"
              rec.css('summary > names > name[role="author"]').each { |n| puts n.css('full_name').text }
              puts "\n"

              puts "ABSTRACT:\n"
              puts pub.abstract
              puts "\n"

              puts "CONTRIBUTORS:\n"
              rec.css('contributors > contributor > name[role="researcher_id"]').each do |n|
                puts n.css('full_name').text
                puts n.attribute('orcid_id')
                puts "\n"
              end

              puts "GRANTS:\n"
              rec.css('grants > grant').each do |g|
                puts g.css('grant_agency').text
                g.css('grant_ids > grant_id').each do |gid|
                  puts gid.text
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
