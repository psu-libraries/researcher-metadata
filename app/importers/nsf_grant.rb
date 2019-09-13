class NSFGrant
  def initialize(parsed_grant)
    @parsed_grant = parsed_grant
  end

  def title
    parsed_grant.css('AwardTitle').text.strip.presence
  end

  private

  attr_reader :parsed_grant
end