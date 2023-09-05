# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongFileVersionCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.wrong_file_version.order('wrong_oa_version_notification_sent_at DESC NULLS FIRST')
  end

  def email_author(publications)
    FacultyNotificationsMailer.wrong_file_version(publications).deliver_now
    publications.each do |pub|
      pub.wrong_oa_version_notification_sent_at = DateTime.current
      pub.save!
    end
  end
end
  