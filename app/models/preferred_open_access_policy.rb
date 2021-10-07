class PreferredOpenAccessPolicy
  def initialize(publication)
    @publication = publication
  end

  def url
    publication.scholarsphere_open_access_url.presence ||
      publication.open_access_url.presence ||
      publication.user_submitted_open_access_url.presence
  end

  private

    attr_reader :publication
end
