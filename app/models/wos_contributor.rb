class WOSContributor
  def initialize(parsed_contributor)
    @parsed_contributor = parsed_contributor
  end

  def name
    WOSAuthorName.new(parsed_contributor.css('name[role="researcher_id"] > full_name').text)
  end

  def orcid
    parsed_contributor.css('name[role="researcher_id"]').attribute('orcid_id').try(:value).try(:strip)
  end

  private

  attr_reader :parsed_contributor
end
