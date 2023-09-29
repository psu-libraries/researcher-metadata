# frozen_string_literal: true

class ActivityInsightOAWorkflow::PermissionsCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.needs_manual_permissions_review
  end
end
