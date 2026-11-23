# frozen_string_literal: true

class ActivityInsightOAWorkflow::NoPolicyFoundCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.no_policy_found.order(:doi)
  end
end
