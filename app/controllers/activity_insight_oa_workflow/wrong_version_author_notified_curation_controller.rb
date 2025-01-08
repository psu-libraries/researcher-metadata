# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongVersionAuthorNotifiedCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.wrong_version_author_notified.order('wrong_oa_version_notification_sent_at DESC')
  end

  def email_author
    publications = Publication.wrong_version_author_notified.where(id: params[:publications])

    FacultyNotificationsMailer.wrong_file_version(publications).deliver_now
    ActiveRecord::Base.transaction do
      publications.each do |pub|
        pub.update_column(:wrong_oa_version_notification_sent_at, Time.current)
        pub.activity_insight_oa_files.each do |file|
          file.increment!(:wrong_version_emails_sent)
        end
      end
    end
    flash[:notice] = "Email sent to #{publications.first.activity_insight_upload_user.webaccess_id}"
    redirect_to activity_insight_oa_workflow_wrong_version_author_notified_review_path
  end
end
