# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongVersionAuthorNotifiedCurationController < ActivityInsightOAWorkflow::WrongVersionBaseController
  def index
    @publications = Publication.wrong_version_author_notified.order('wrong_oa_version_notification_sent_at DESC')
  end

  def email_author
    send_email(Publication.wrong_version_author_notified)
    redirect_to activity_insight_oa_workflow_wrong_version_author_notified_review_path
  end
end
