# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongFileVersionCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.wrong_file_version.order('wrong_oa_version_notification_sent_at DESC NULLS FIRST')
  end

  def email_author
    publications = Publication.wrong_file_version.find(params[:publications])

    FacultyNotificationsMailer.wrong_file_version(publications).deliver_now
    ActiveRecord::Base.transaction do
      publications.each do |pub|
        pub.update_column(:wrong_oa_version_notification_sent_at, Time.current)
      end
    end
    flash[:alert] = "Email sent to #{publications.first.activity_insight_file_uploader.webaccess_id}}"
    redirect_to activity_insight_oa_workflow_wrong_file_version_review_path
  end
end
