class FacultyConfirmationsMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/faculty_confirmations_mailer/open_access_waiver_confirmation
  def open_access_waiver_confirmation
    fake_user = OpenStruct.new({ email: 'test@example.com',
                                 name: 'Example User' })
    fake_waiver = OpenStruct.new({ publication_title: 'My Publication',
                                   journal_title: 'Example Journal',
                                   publisher: 'Example Publisher',
                                   doi: 'https://doi.org/10.1000/182',
                                   reason_for_waiver: 'I have my reasons.' })
    FacultyConfirmationsMailer.open_access_waiver_confirmation(fake_user, fake_waiver)
  end
end
