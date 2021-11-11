# frozen_string_literal: true

class AdminNotificationsMailer < ApplicationMailer
  def authorship_claim(authorship)
    @authorship = authorship
    mail to: 'L-FAMS@lists.psu.edu', # TODO: replace this with the real email address once it's known
         subject: 'RMD Authorship Claim',
         from: 'openaccess@psu.edu'
  end
end
