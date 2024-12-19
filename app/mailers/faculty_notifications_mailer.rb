# frozen_string_literal: true

class FacultyNotificationsMailer < ApplicationMailer
  def open_access_reminder(user, publications)
    @user = user
    @publications = publications
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
    profile = UserProfile.new(@publications.first.activity_insight_upload_user)
    mail to: profile.email,
         subject: 'Open Access Post-Print Publication Files in Activity Insight',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def preferred_file_version_none(publications)
    @publications = publications
    profile = UserProfile.new(@publications.first.activity_insight_upload_user)
    mail to: profile.email,
         subject: 'Open Access Post-Print Publication Files in Activity Insight',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end
end
