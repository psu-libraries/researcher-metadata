# frozen_string_literal: true

class ActivityInsightOaWorkflow::DOIVerificationController < ActivityInsightOaWorkflowController
  def index
    @publications = Publication.doi_failed_verification
  end
end
