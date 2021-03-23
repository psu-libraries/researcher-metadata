class ScholarsphereDepositService
  def initialize(deposit, current_user)
    @deposit = deposit
    @current_user = current_user
  end

  def create
    creators_attributes = deposit.publication.users.order('authorships.author_number ASC').map do |u|
      {
        display_name: u.name,
        actor_attributes: {
          psu_id: u.webaccess_id,
          surname: u.last_name,
          given_name: u.first_name,
          email: "#{u.webaccess_id}@psu.edu"
        }
      }
    end

    metadata = {
      title: deposit.publication.title,
      description: deposit.publication.abstract,
      published_date: deposit.publication.published_on,
      work_type: 'article',
      visibility: 'open',
      creators_attributes: creators_attributes
    }

    files = deposit.file_uploads.map do |sfu|
      File.new(sfu.file.file.file)
    end

    depositor = {
      psu_id: current_user.webaccess_id,
      surname: current_user.last_name,
      given_name: current_user.first_name,
      email: "#{current_user.webaccess_id}@psu.edu"
    }

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: metadata,
      files: files,
      depositor: depositor
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
