class WOSGrant
  def initialize(parsed_grant)
    @parsed_grant = parsed_grant
  end

  def wos_agency
    parsed_grant.css('grant_agency').text.try(:strip)
  end

  def ids
    parsed_grant.css('grant_ids > grant_id').map { |i| i.text.try(:strip) }
  end

  private

  attr_reader :parsed_grant
end