# frozen_string_literal: true

class ActivityInsightOaWorkflow::UnknownVersionListController < ActivityInsightOaWorkflowController
  def index
    @publications = Publication.unknown_version
  end
end
