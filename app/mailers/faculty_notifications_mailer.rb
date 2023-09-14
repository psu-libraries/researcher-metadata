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
    mail to: "#{publications.first.activity_insight_upload_user.webaccess_id}@psu.edu",
         subject: 'Open Access Post-Print Publication Files in Activity Insight',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end
end
