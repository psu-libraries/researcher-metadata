# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongFileVersionCurationController < ActivityInsightOAWorkflow::WrongVersionBaseController
  def index
    @publications = Publication.wrong_file_version
      .left_joins(:activity_insight_oa_files)
      .select('publications.*, MIN(activity_insight_oa_files.created_at) AS oldest_file_date')
      .group('publications.id')
      .order('oldest_file_date ASC')
  end

  def email_author
    send_email(Publication.wrong_file_version)
    redirect_to activity_insight_oa_workflow_wrong_file_version_review_path
  end
end
