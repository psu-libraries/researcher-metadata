# frozen_string_literal: true

class ActivityInsightOAWorkflow::PreferredFileVersionNoneCurationController < ActivityInsightOAWorkflowController
    def index
      @publications = Publication.preferred_file_version_none
    end
  
    def email_author
      publications = Publication.preferred_file_version_none.find(params[:publications])
  
      FacultyNotificationsMailer.preferred_file_version_none(publications).deliver_now
      ActiveRecord::Base.transaction do
        publications.each do |pub|
          pub.update_column(:preferred_file_version_none_email_sent, true)
        end
      end
      flash[:notice] = "Email sent to #{publications.first.activity_insight_upload_user.webaccess_id}}"
      #trigger export job to update AI status to 'Cannot Deposit'
      redirect_to activity_insight_oa_workflow_preferred_file_version_none_review_path
    end
  end
  