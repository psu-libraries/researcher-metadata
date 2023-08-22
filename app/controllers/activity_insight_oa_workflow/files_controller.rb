# frozen_string_literal: true

class ActivityInsightOAWorkflow::FilesController < ActivityInsightOAWorkflowController
  def download
    file = ActivityInsightOAFile.find(params[:activity_insight_oa_file_id])
    send_file(file.stored_file_path)
  end
end
