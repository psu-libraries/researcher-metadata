# frozen_string_literal: true

class WebOfSciencePublication
  def initialize(parsed_pub)
    @parsed_pub = parsed_pub
  end

  def wos_id
    parsed_pub.css('UID').text.strip
  end

  def title
    parsed_pub.css('title[type="item"]').first.text.strip.presence
  end

  def importable?
    article? && penn_state? && not_imported?
  end

  def doi
    raw_doi = parsed_pub.css('dynamic_data > cluster_related > identifiers > identifier[type="doi"]')
      .first.try(:[], :value).try(:strip) ||
      parsed_pub.css('dynamic_data > cluster_related > identifiers > identifier[type="xref_doi"]')
        .first.try(:[], :value).try(:strip)
    DOISanitizer.new(raw_doi).url
  end

  def issn
    parsed_pub.css('dynamic_data > cluster_related > identifiers > identifier[type="issn"]')
      .first.try(:[], :value).try(:strip)
  end

  def abstract
    parsed_pub.css('abstracts > abstract > abstract_text').map { |a| a.try(:text).try(:strip) }.join("\n\n").strip.presence
  end

  def journal_title
    parsed_pub.css('title[type="source"]').text.strip
  end

  def issue
    pub_info.attribute('issue').try(:value)
  end

  def volume
    pub_info.attribute('vol').try(:value)
  end

  def page_range
    parsed_pub.css('pub_info > page').text.strip
  end

  def publisher
    parsed_pub.css('publishers > publisher > names > name[role="publisher"] > full_name').text.strip
  end

  def publication_date
    Date.parse(pub_info.attribute('sortdate').value) if pub_info.attribute('sortdate')
  end

  def author_names
    parsed_pub.css('summary > names > name[role="author"]').map do |n|
      WOSAuthorName.new(n.css('full_name').text)
    end
  end

  def grants
    parsed_pub.css('grants > grant').map do |g|
      WOSGrant.new(g)
    end
  end

  def contributors
    parsed_pub.css('contributors > contributor').map do |c|
      WOSContributor.new(c)
    end
  end

  def orcids
    contributors.filter_map(&:orcid)
  end

  private

    attr_reader :parsed_pub

    def article?
      parsed_pub.css('doctypes > doctype').map(&:text).include?('Article')
    end

    def penn_state?
      !!parsed_pub.css('addresses')
        .find do |a|
        a.css('address_name > address_spec > organizations')
          .find { |o| o.text =~ /Penn State Univ/ }
      end
    end

    def not_imported?
      !PublicationImport.find_by(source: 'Web of Science', source_identifier: wos_id)
    end

    def pub_info
      parsed_pub.css('pub_info')
    end
end
