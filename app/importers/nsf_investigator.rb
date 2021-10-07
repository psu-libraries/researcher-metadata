class NSFInvestigator
  def initialize(parsed_investigator)
    @parsed_investigator = parsed_investigator
  end

  def first_name
    text_for_element('FirstName')
  end

  def last_name
    text_for_element('LastName')
  end

  def psu_email_name
    email_address = text_for_element('EmailAddress')
    if /@psu.edu/i.match? email_address
      email_address.split('@').first
    end
  end

  private

    def text_for_element(element)
      parsed_investigator.css(element).text.strip.presence
    end

    attr_reader :parsed_investigator
end
