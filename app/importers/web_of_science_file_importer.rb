require 'nokogiri'
require 'byebug'

class WebOfScienceFileImporter
  def call
    Nokogiri::XML::Reader(File.open('/Volumes/unicorn/CORE_2013-2018/2013_CORE/WR_2013_20190215154350_CORE_0022.xml')).each do |node|
      if node.name == 'REC' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        rec = Nokogiri::XML(node.outer_xml).at('REC')

        if rec.css('doctypes > doctype').map { |dt| dt.text }.include?("Article") && rec.css('addresses').detect { |a| a.css('address_name > address_spec > organizations').detect { |o| o.text =~ /Penn State Univ/ } }
          rec.css('summary > names > name[role="author"]').each do |n|
            user = User.find_by(first_name: n.css('first_name').text.split(' ').first, last_name: n.css('last_name').text)

            if user
              puts "USER:  #{user.name}"

              puts "TITLE:\n"
              puts rec.css('title[type="item"]').first.text
              puts "\n"

              puts "NAMES:\n"
              rec.css('summary > names > name[role="author"]').each { |n| puts n.css('full_name').text }
              puts "\n"

              puts "ABSTRACT:\n"
              rec.css('abstracts > abstract > abstract_text').each do |a|
                puts a.text
              end
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
