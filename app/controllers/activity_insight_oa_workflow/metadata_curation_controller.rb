# frozen_string_literal: true

class ActivityInsightOAWorkflow::MetadataCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.ready_for_metadata_review
  end
end
