# frozen_string_literal: true

class ScholarsphereDepositService
  class DepositFailed < RuntimeError; end

  def initialize(deposit, current_user)
    @deposit = deposit
    @current_user = current_user
  end

  def create
    logger = Logger.new('log/scholarsphere_deposit.log')

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: deposit.files,
      depositor: current_user.webaccess_id
    )

    response = ingest.publish
    response_body = JSON.parse(response.body)

    if response.status == 200
      scholarsphere_publication_uri = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{response_body['url']}"
      deposit.record_success(scholarsphere_publication_uri)
      profile = UserProfile.new(current_user)
      FacultyConfirmationsMailer.scholarsphere_deposit_confirmation(profile, deposit).deliver_now
    else
      logger.info response.inspect
      raise DepositFailed.new(response.body)
    end

    logger.info response.inspect
  end

  private

    attr_reader :deposit, :current_user
end
