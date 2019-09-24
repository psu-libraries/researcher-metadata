class NSFGrant
  def initialize(parsed_grant)
    @parsed_grant = parsed_grant
  end

  def importable?
    !!parsed_grant.css('Institution').detect do |i|
      /Pennsylvania State Univ/i.match i.css('Name').text.strip
    end
  end

  def title
    text_for_element('AwardTitle')
  end

  def start_date
    date = text_for_element('AwardEffectiveDate')
    Date.strptime(date, "%m/%d/%Y") if date
  end

  def abstract
    text_for_element('AbstractNarration')
  end

  def amount_in_dollars
    text_for_element('AwardAmount').try(:to_i)
  end

  def identifier
    text_for_element('AwardID')
  end

  def agency_name
    "National Science Foundation"
  end

  private

  attr_reader :parsed_grant

  def text_for_element(element)
    parsed_grant.css(element).text.strip.presence
  end
end