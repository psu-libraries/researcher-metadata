# frozen_string_literal: true

class AdminNotificationsMailer < ApplicationMailer
  def authorship_claim(authorship)
    @authorship = authorship
    mail to: 'rmd-admin@psu.edu',
         subject: 'RMD Authorship Claim',
         from: 'openaccess@psu.edu'
  end
end
