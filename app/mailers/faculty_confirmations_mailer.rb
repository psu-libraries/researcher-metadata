class FacultyConfirmationsMailer < ApplicationMailer
  def open_access_waiver_confirmation(user, waiver)
    @waiver = waiver
    @user = user
    mail to: @user.email,
         subject: "PSU Open Access Policy Waiver for Requested Article",
         from: "no-reply@#{ActionMailer::Base.default_url_options[:host]}",
         reply_to: "openaccess@psu.edu"
  end
end
