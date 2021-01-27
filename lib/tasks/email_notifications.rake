namespace :email_notifications do
  desc 'Send reminder emails about potential open access publications to all applicable users'
  task send_all_open_access_reminders: :environment do
    OpenAccessNotifier.new.send_notifications
  end

  desc 'Send reminder emails about potential open access publications only to users in the Penn State University Libraries'
  task send_library_open_access_reminders: :environment do
    psu_libraries = Organization.find_by(pure_external_identifier: 'CAMPUS-UL')
    OpenAccessNotifier.new(psu_libraries.all_users).send_notifications
  end
end
