# frozen_string_literal: true

class ActivityInsightOAWorkflow::MetadataCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.ready_for_metadata_review
  end

  def show
    @publication = Publication.ready_for_metadata_review.find(params[:publication_id])
  end
end
