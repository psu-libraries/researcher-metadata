class FacultyConfirmationsMailer < ApplicationMailer
  def open_access_waiver_confirmation(user, waiver)
    @waiver = waiver
    @user = user
    mail to: @user.email,
         subject: "open access waiver confirmation",
         from: "no-reply@#{ActionMailer::Base.default_url_options[:host]}"
  end
end
