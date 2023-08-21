# frozen_string_literal: true

class ScholarsphereUploadJob < ApplicationJob
  queue_as Settings.delayed_job.upload_queue

  def perform(deposit_id, user_id)
    Scholarsphere::Client.reset
    deposit = ScholarsphereWorkDeposit.find(deposit_id)
    user = User.find(user_id)
    service = ScholarsphereDepositService.new(deposit, user)
    service.create
  rescue Exception => e
    deposit.record_failure(e.to_s)
    profile = UserProfile.new(user)
    FacultyNotificationsMailer.scholarsphere_deposit_failure(profile, deposit).deliver_now
    raise
  end
end
