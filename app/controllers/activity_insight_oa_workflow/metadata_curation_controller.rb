# frozen_string_literal: true

class ActivityInsightOAWorkflow::MetadataCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.ready_for_metadata_review.to_a.sort_by! { |p| p.ai_file_for_deposit.created_at }
  end

  def show
    @publication = Publication.ready_for_metadata_review.find(params[:publication_id])
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = I18n.t('activity_insight_oa_workflow.metadata_curation_list.record_not_found')
    redirect_to activity_insight_oa_workflow_metadata_review_path
  end

  def create_scholarsphere_deposit
    publication = Publication.find(params[:publication_id])
    activity_insight_oa_file = publication.ai_file_for_deposit
    authorship = Authorship.find_by(user: activity_insight_oa_file.user,
                                    publication: publication)
    @deposit = ScholarsphereWorkDeposit.new_from_authorship(authorship,
                                                            rights: activity_insight_oa_file.license,
                                                            publisher_statement: activity_insight_oa_file.set_statement,
                                                            embargoed_until: activity_insight_oa_file.embargo_date,
                                                            deposit_agreement: true,
                                                            deposited_at: Time.now,
                                                            deposit_workflow: 'Activity Insight OA Workflow')
    @deposit.file_uploads = []
    ss_file_upload = ScholarsphereFileUpload.new
    ss_file_upload.file = activity_insight_oa_file.file_download_location.file
    ss_file_upload.save!
    @deposit.file_uploads << ss_file_upload
    @deposit.save!

    ScholarsphereUploadJob.perform_later(@deposit.id, activity_insight_oa_file.user.id)

    flash[:notice] = I18n.t('activity_insight_oa_workflow.scholarsphere_deposit.success')
    redirect_to activity_insight_oa_workflow_metadata_review_path
  end
end
