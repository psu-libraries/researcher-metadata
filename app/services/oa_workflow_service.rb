# frozen_string_literal: true

class OaWorkflowService

  def workflow
    Publication.needs_doi_verification.each do |pub|
      DoiVerificationJob.new.perform(pub)
    end
  end
end