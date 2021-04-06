class ScholarsphereUploadJob < ApplicationJob
  queue_as "scholarsphere-uploads-#{`hostname`}".strip

  def perform(deposit_id, user_id)
    deposit = ScholarsphereWorkDeposit.find(deposit_id)
    user = User.find(user_id)
    service = ScholarsphereDepositService.new(deposit, user)
    service.create
  rescue Exception => e
    deposit.record_failure(e.to_s)
    raise
  end
end
