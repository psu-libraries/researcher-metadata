# frozen_string_literal: true

class ActivityInsightOAWorkflow::PreferredVersionCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.needs_manual_preferred_version_check
  end
end
