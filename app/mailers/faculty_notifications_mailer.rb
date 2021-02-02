class FacultyNotificationsMailer < ApplicationMailer
  def open_access_reminder(user, old_publications, new_publications)
    @user = user
    @old_publications = old_publications
    @new_publications = new_publications
    mail to: @user.email,
         subject: "Penn State Open Access Policy: Articles to Upload",
         from: "openaccess@psu.edu",
         reply_to: "openaccess@psu.edu"
  end
end
