# frozen_string_literal: true

class ScholarsphereDepositService
  class DepositFailed < RuntimeError; end

  def initialize(deposit, user)
    @deposit = deposit
    @user = user
  end

  def create
    logger = Logger.new('log/scholarsphere_deposit.log')

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: deposit.metadata,
      files: deposit.files,
      depositor: user.webaccess_id,
      publish: deposit.standard_oa_workflow?
    )

    response = ingest.publish
    response_body = JSON.parse(response.body)

    # Draft works will return a 201
    if response.status == 201 || response_body['edit_url'] != nil
      edit_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{response_body['edit_url']}"
      cache_key = "deposit:#{deposit.id}"
      Rails.cache.write(
        cache_key,
        { status: 'completed', user_id: current_user.id, edit_url: edit_url },
        expires_in: 15.minutes
      )
    # Published works will return a 200
    elsif response.status == 200
      scholarsphere_publication_uri = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{response_body['url']}"
      deposit.record_success(scholarsphere_publication_uri)
      profile = UserProfile.new(user)
      unless deposit.standard_oa_workflow?
        FacultyConfirmationsMailer.ai_oa_workflow_scholarsphere_deposit_confirmation(profile, deposit).deliver_now
        AiOAStatusExportJob.perform_later(deposit.activity_insight_oa_file_id, 'Deposited to ScholarSphere')
      end
    else
      if deposit.standard_oa_workflow?
        cache_key = "deposit:#{deposit.id}"
        Rails.cache.write(
          cache_key,
          { status: 'failed', error: e.message },
          expires_in: 15.minutes
          )
      end
      logger.info response.inspect
      raise DepositFailed.new(response.body)
    end

    logger.info response.inspect
  end

  private

    attr_reader :deposit, :user
end
