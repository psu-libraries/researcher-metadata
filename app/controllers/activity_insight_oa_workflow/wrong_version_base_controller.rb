# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongVersionBaseController < ActivityInsightOAWorkflowController
  private

    def send_email(publications_scope)
      publications = publications_scope.where(id: params[:publications])

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
    end
end
