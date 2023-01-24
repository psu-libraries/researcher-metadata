# frozen_string_literal: true

class ActivityInsightOaWorkflow::DOIVerificationController < ActivityInsightOaWorkflowController
  def index
    @publications = Publication.doi_unverified.first(50)
  end
end
