class WebOfSciencePublication
  def initialize(parsed_pub)
    @parsed_pub = parsed_pub
  end

  def title
    parsed_pub.css('title[type="item"]').first.text.strip.presence
  end

  def importable?
    article? && penn_state?
  end

  def doi
    parsed_pub.css('dynamic_data > cluster_related > identifiers > identifier[type="doi"]').first.try(:[], :value).try(:strip)
  end

  def abstract
    parsed_pub.css('abstracts > abstract > abstract_text').map { |a| a.try(:text).try(:strip) }.join("\n\n").strip.presence
  end

  def author_names
    parsed_pub.css('summary > names > name[role="author"]').map do |n|
      WOSAuthorName.new(n.text.strip)
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

  private

  attr_reader :parsed_pub

  def article?
    parsed_pub.css('doctypes > doctype').map { |dt| dt.text }.include?("Article")
  end

  def penn_state?
    !!parsed_pub.css('addresses').
      detect { |a| a.css('address_name > address_spec > organizations').
        detect { |o| o.text =~ /Penn State Univ/ } }
  end
end
