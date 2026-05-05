# frozen_string_literal: true

class NSFAward
  def initialize(parsed_award)
    @parsed_award = parsed_award
  end

  def title
    parsed_award['title']
  end

  def start_date
    parse_date(parsed_award['startDate'])
  end

  def end_date
    parse_date(parsed_award['expDate'])
  end

  def abstract
    parsed_award['abstractText']
  end

  def amount_in_dollars
    parsed_award['fundsObligatedAmt'].try(:to_i)
  end

  def identifier
    parsed_award['id']
  end

  def agency_name
    # There are, inexplicably, a subset of award records in the NSF dataset from the year 2004
    # where the agency is blank (and many of these records also lack a title). Since all of the
    # other records in the dataset have an `agency` value of 'NSF' and since these records with
    # blank agency values all appear to have NSF identifiers, we're going to assume that the
    # agency should be recorded as 'NSF' for them as well.
    parsed_award['agency'].presence || 'NSF'
  end

  def pi_first_name
    parsed_award['piFirstName'].presence
  end

  def pi_last_name
    parsed_award['piLastName'].presence
  end

  def pi_middle_initial
    parsed_award['piMiddeInitial'].presence
  end

  def pi_psu_email_name
    email_address = parsed_award['piEmail']
    if email_address.present? && /psu.edu/i.match?(email_address)
      email_address.split('@').first
    end
  end

  def publications
    pubs = parsed_award['jrnl']
    pubs&.map { |p| NSFAwardPublication.new(p) } || []
  end

  private

    attr_reader :parsed_award

    def parse_date(date_string)
      Date.strptime(date_string, '%m/%d/%Y') if date_string
    end
end
