namespace :email_notifications do
  desc 'Send reminder emails about potential open access publications'
  task send_open_access_reminders: :environment do
    OpenAccessNotifier.new.send_notifications
  end
end
