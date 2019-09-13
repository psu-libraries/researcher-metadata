class WOSGrant
  def initialize(parsed_grant)
    @parsed_grant = parsed_grant
  end

  def wos_agency
    parsed_grant.css('grant_agency').text.try(:strip)
  end

  def agency
    if (wos_agency =~ /National Science Foundation/i ||
       wos_agency =~ /NSF/) &&
       wos_agency !~ /Chinese NSF/i &&
       wos_agency !~ /CNSF/ &&
       wos_agency !~ /NSFC/ &&
       wos_agency !~ /NSF of China/i &&
       wos_agency !~ /National Science Foundation of China/i &&
       wos_agency !~ /Swiss National Science Foundation/i &&
       wos_agency !~ /GNSF/ &&
       wos_agency !~ /SNSF/
      "National Science Foundation"
    end
  end

  def ids
    parsed_grant.css('grant_ids > grant_id').map { |i| WOSGrantID.new(self, i) }
  end

  private

  attr_reader :parsed_grant
end