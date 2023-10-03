# frozen_string_literal: true

class ActivityInsightOAWorkflow::MetadataCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.ready_for_metadata_review.to_a.sort_by! { |p| p.ai_file_for_deposit.created_at }
  end

  def show
    @publication = Publication.ready_for_metadata_review.find(params[:publication_id])
  end
end
