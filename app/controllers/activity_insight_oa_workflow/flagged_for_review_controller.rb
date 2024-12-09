# frozen_string_literal: true

class ActivityInsightOAWorkflow::FlaggedForReviewController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.flagged_for_review
  end
end
