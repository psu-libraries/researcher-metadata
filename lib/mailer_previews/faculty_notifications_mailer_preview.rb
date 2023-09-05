# frozen_string_literal: true

class FacultyNotificationsMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/faculty_notifications_mailer/open_access_reminder
  def open_access_reminder
    fake_user = OpenStruct.new({ email: 'test@example.com',
                                 name: 'Example User' })
    pub1 = OpenStruct.new({ title: 'Example Publication One' })
    pub2 = OpenStruct.new({ title: 'Example Publication Two' })
    pub3 = OpenStruct.new({ title: 'Example Publication Three' })
    old_fake_pubs = [pub1, pub2]
    new_fake_pubs = [pub3]

    FacultyNotificationsMailer.open_access_reminder(fake_user, old_fake_pubs, new_fake_pubs)
  end

  # Accessible from http://localhost:3000/rails/mailers/faculty_notifications_mailer/wrong_file_version
  def wrong_file_version
    ai_oa_file = OpenStruct.new(user_id: 1, version_status_display: 'Final Published Version')
    pub1 = OpenStruct.new({ title: 'Example Publication One', preferred_version_display: 'Accepted Manuscript', activity_insight_oa_files: [ai_oa_file] })
    pub2 = OpenStruct.new({ title: 'Example Publication Two', preferred_version_display: 'Accepted Manuscript', activity_insight_oa_files: [ai_oa_file] })
    pub3 = OpenStruct.new({ title: 'Example Publication Three', preferred_version_display: 'Accepted Manuscript', activity_insight_oa_files: [ai_oa_file] })
    pubs = [pub1, pub2, pub3]

    FacultyNotificationsMailer.wrong_file_version(pubs)
  end
end
