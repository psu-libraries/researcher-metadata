class FacultyNotificationsMailer < ApplicationMailer
  def open_access_reminder(user, publications)
    @user = user
    @publications = publications
    mail to: @user.email,
         subject: "PSU Open Access Policy Reminder",
         from: "openaccess@psu.edu",
         reply_to: "openaccess@psu.edu"
  end
end
