# frozen_string_literal: true

class ScholarsphereDepositService
  class DepositFailed < RuntimeError; end

  def initialize(deposit, user)
    @deposit = deposit
    @user = user
  end

  def create_draft
    logger = Logger.new('log/scholarsphere_deposit.log')
    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: deposit.files,
      depositor: user.webaccess_id,
      publish: false
    )

    response = ingest.create
    raise DepositFailed.new('Something went wrong.') unless response

    response_body = JSON.parse(response.body)

    # Draft works will return a 201
    if response.status == 201 || !response_body['edit_url'].nil?
      base_url = ResearcherMetadata::Application.scholarsphere_base_uri
      scholarsphere_publication_uri = "#{base_url}#{response_body['url']}"
      deposit.update(draft_scholarsphere_work_deposit_url: scholarsphere_publication_uri)
      "#{base_url}#{response_body['edit_url']}"
    else
      logger.info response.inspect
      raise DepositFailed.new(response.body)
    end
  rescue StandardError => e
    logger.info e.to_s
    raise DepositFailed.new(e.to_s)
  end

  def create
    logger = Logger.new('log/scholarsphere_deposit.log')

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: deposit.files,
      depositor: user.webaccess_id
    )

    response = ingest.create
    response_body = JSON.parse(response.body)

    if response.status == 200
      scholarsphere_publication_uri = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{response_body['url']}"
      deposit.record_success(scholarsphere_publication_uri)
      profile = UserProfile.new(user)
      unless deposit.standard_oa_workflow?
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
