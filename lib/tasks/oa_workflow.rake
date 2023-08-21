# frozen_string_literal: true

desc 'Move publications through the open access workflow'
task oa_workflow: :environment do
  OAWorkflowService.new.workflow
end
