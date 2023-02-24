# frozen_string_literal: true

class ActivityInsightOAWorkflow::UnknownVersionListController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.unknown_version
  end
end
