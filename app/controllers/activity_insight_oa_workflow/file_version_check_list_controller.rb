# frozen_string_literal: true

class ActivityInsightOAWorkflow::FileVersionCheckListController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.file_version_check_failed
  end
end
