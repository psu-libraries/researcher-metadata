# frozen_string_literal: true

class FacultyNotificationsMailer < ApplicationMailer
  def open_access_reminder(user, old_publications, new_publications)
    @user = user
    @old_publications = old_publications
    @new_publications = new_publications
    mail to: @user.email,
         subject: 'Penn State Open Access Policy: Articles to Upload',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def scholarsphere_deposit_failure(user, deposit)
    @user = user
    @deposit = deposit
    mail to: @user.email,
         subject: 'Your publication could not be deposited in ScholarSphere',
         from: 'scholarsphere@psu.edu',
         reply_to: 'scholarsphere@psu.edu'
  end

  def wrong_file_version(publications)
    @publications = publications
    #will need to change the mail to to whatever connects a publication to the activity insight uploader's email
    mail to: @publications.first.confirmed_users.first.psu_identity.data['universityEmail'],
         subject: 'Open Access Post-Print Publication Files in Activity Insight',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end
end
