# frozen_string_literal: true

class AdminNotificationsMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/admin_notifications_mailer/authorship_claim
  def authorship_claim
    fake_auth = OpenStruct.new({ title: 'A Test Journal Article',
                                 user_name: 'Example User',
                                 id: 3 })

    AdminNotificationsMailer.authorship_claim(fake_auth)
  end
end
