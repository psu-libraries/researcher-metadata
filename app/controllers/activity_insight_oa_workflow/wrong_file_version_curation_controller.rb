# frozen_string_literal: true

class ActivityInsightOAWorkflow::WrongFileVersionCurationController < ActivityInsightOAWorkflowController
  def index
    @publications = Publication.wrong_file_version.order('email_last_sent_at DESC NULLS FIRST')
  end
end
  