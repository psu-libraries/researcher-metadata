# frozen_string_literal: true

desc 'Move publications through the open access workflow'
task oa_workflow: :environment do
  OAWorkflowService.new.workflow
end

desc 'One time update to set all permissions flags'
task permissions_check_all: :environment do
  ActivityInsightOAFile.all.each do |file|
    file.update!(permissions_last_checked_at: Time.current)
    FilePermissionsCheckJob.perform_later(file.id)
  end
end
