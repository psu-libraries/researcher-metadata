class ScholarsphereDepositService
  def initialize(deposit, current_user)
    @deposit = deposit
    @current_user = current_user
  end

  def create
    files = deposit.file_uploads.map do |sfu|
      File.new(sfu.stored_file_path)
    end

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: files,
      depositor: current_user.webaccess_id
    )

    response = ingest.publish

    response_body = JSON.parse(response.body)
    if response.status == 200
      scholarsphere_uri = URI(Rails.application.config.x.scholarsphere['SS4_ENDPOINT'])
      scholarsphere_publication_uri = "#{scholarsphere_uri.scheme}://#{scholarsphere_uri.host}#{response_body["url"]}"
      deposit.record_success(scholarsphere_publication_uri)
    else
      deposit.record_failure(response.body)
    end

    logger = Logger.new('log/scholarsphere_deposit.log')
    logger.debug response.inspect
  end

  private

  attr_reader :deposit, :current_user
end
