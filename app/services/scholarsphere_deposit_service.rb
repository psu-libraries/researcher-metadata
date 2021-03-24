class ScholarsphereDepositService
  def initialize(deposit, current_user)
    @deposit = deposit
    @current_user = current_user
  end

  def create
    creators = deposit.publication.contributor_names.order('position ASC').map do |cn|
      cn.to_scholarsphere_creator
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
