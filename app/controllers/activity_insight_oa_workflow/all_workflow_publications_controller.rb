# frozen_string_literal: true

class ActivityInsightOAWorkflow::AllWorkflowPublicationsController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.activity_insight_oa_publication.order('created_at ASC NULLS FIRST')
  end
end