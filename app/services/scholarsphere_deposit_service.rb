class ScholarsphereDepositService
  def initialize(deposit, current_user)
    @deposit = deposit
    @current_user = current_user
  end

  def create
    # This bit needs to change so that we provide the full list of authors and not just
    # the Penn State people who are authors. However, we need to provide PSU access IDs
    # for Penn State people (and ORCID IDs for those who have them), while providing only
    # a name for non-Penn State people. To do this reliably and to get the records in the
    # correct order, we're going to need to link User records to ContributorName records
    # upon import.
    creators = deposit.publication.users.order('authorships.author_number ASC').map do |u|
      { psu_id: u.webaccess_id }
    end

    metadata = {
      title: deposit.publication.title,
      description: deposit.publication.abstract,
      published_date: deposit.publication.published_on,
      work_type: 'article',
      visibility: 'open',
      rights: 'https://creativecommons.org/licenses/by/4.0/',
      creators: creators
    }

    files = deposit.file_uploads.map do |sfu|
      File.new(sfu.file.file.file)
    end

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: metadata,
      files: files,
      depositor: current_user.webaccess_id
    )

    response = ingest.publish

    response_body = JSON.parse(response.body)
    if response.status == 200
      scholarsphere_uri = URI(Rails.application.config.x.scholarsphere['SS4_ENDPOINT'])
      scholarsphere_publication_uri = "#{scholarsphere_uri.scheme}://#{scholarsphere_uri.host}#{response_body["url"]}"
      deposit.publication.update!(scholarsphere_open_access_url: scholarsphere_publication_uri)
    end

    Rails.logger.debug response.inspect
  end

  private

  attr_reader :deposit, :current_user
end
