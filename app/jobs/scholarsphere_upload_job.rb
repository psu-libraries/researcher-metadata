class ScholarsphereUploadJob < ApplicationJob
  def perform(deposit_id, user_id)
    deposit = ScholarsphereWorkDeposit.find(deposit_id)
    user = User.find(user_id)
    service = ScholarsphereDepositService.new(deposit, user)
    service.create
  end
end
