# frozen_string_literal: true

class ActivityInsightOAWorkflow::DOIVerificationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.doi_failed_verification
  end
end
