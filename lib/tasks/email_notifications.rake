namespace :email_notifications do
  desc 'Send reminder emails about potential open access publications to all applicable users'
  task send_all_open_access_reminders: :environment do
    OpenAccessNotifier.new.send_notifications
  end

  desc 'Send reminder emails about potential open access publications only to users in the University Park Libraries'
  task send_library_open_access_reminders: :environment do
    up_library = Organization.find_by(pure_external_identifier: 'COLLEGE-UL')
    OpenAccessNotifier.new(up_library.all_users).send_notifications
  end
end
