# frozen_string_literal: true

class ScholarsphereDepositService
  class DepositFailed < RuntimeError; end

  def initialize(deposit, user)
    @deposit = deposit
    @user = user
  end

  def create(ai_oa_file_id = nil)
    logger = Logger.new('log/scholarsphere_deposit.log')

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: deposit.files,
      depositor: user.webaccess_id
    )

    response = ingest.publish
    response_body = JSON.parse(response.body)

    if response.status == 200
      scholarsphere_publication_uri = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{response_body['url']}"
      deposit.record_success(scholarsphere_publication_uri)
      profile = UserProfile.new(user)
      if deposit.standard_oa_workflow?
        FacultyConfirmationsMailer.scholarsphere_deposit_confirmation(profile, deposit).deliver_now
      else
        FacultyConfirmationsMailer.ai_oa_workflow_scholarsphere_deposit_confirmation(profile, deposit).deliver_now
        AiOAStatusExportJob.perform_later(deposit.activity_insight_oa_file_id, 'Deposited to ScholarSphere')
      end
    else
      logger.info response.inspect
      raise DepositFailed.new(response.body)
    end

    logger.info response.inspect
  end

  private

    attr_reader :deposit, :user
end
