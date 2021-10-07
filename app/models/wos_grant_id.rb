class WOSGrantID
  def initialize(grant, parsed_grant_id)
    @grant = grant
    @parsed_grant_id = parsed_grant_id
  end

  def wos_value
    parsed_grant_id.text.strip
  end

  def value
    if grant.agency == 'National Science Foundation'
      /\d+-*\d+/.match(wos_value)[0].gsub('-', '')
    end
  end

  private

    attr_reader :grant, :parsed_grant_id
end
