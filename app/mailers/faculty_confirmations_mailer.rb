# frozen_string_literal: true

class FacultyConfirmationsMailer < ApplicationMailer
  def open_access_waiver_confirmation(user, waiver)
    @waiver = waiver
    @user = user
    mail to: @user.email,
         subject: 'PSU Open Access Policy Waiver for Requested Article',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def scholarsphere_deposit_confirmation(user, deposit)
    @user = user
    @deposit = deposit
    mail to: @user.email,
         subject: 'File deposited in ScholarSphere',
         from: 'scholarsphere@psu.edu',
         reply_to: 'scholarsphere@psu.edu'
  end

  def ai_oa_workflow_scholarsphere_deposit_confirmation(user, deposit)
    @user = user
    @deposit = deposit
    mail to: @user.email,
         subject: 'Publication deposited to ScholarSphere',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end
end
