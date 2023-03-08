# frozen_string_literal: true

class ActivityInsightOAWorkflow::PermissionsCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.permissions_check_failed
  end
end
