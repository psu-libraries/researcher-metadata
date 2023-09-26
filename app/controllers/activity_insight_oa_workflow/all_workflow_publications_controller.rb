# frozen_string_literal: true

class ActivityInsightOAWorkflow::AllWorkflowPublicationsController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.troubleshooting_list
  end
end