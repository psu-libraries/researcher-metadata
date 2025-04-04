# frozen_string_literal: true

namespace :email_notifications do
  desc 'Send reminder emails about potential open access publications to all applicable users'
  task send_all_open_access_reminders: :environment do
    OpenAccessNotifier.new.send_notifications
  end

  desc 'Send reminder emails about potential open access publications to applicable users up to the number passed as an argument (or the configured number as default)'
  task :send_capped_open_access_reminders, [:cap] => :environment do |_task, args|
    if OANotificationSetting.not_active?
      $stdout.puts 'Notifications are turned off'
      next
    end

    cap = (args[:cap] || OANotificationSetting.email_cap).to_i
    OpenAccessNotifier.new.send_notifications_with_cap(cap)
  end

  desc 'Send reminder emails about potential open access publications only to applicable users in the Penn State University Libraries'
  task send_library_open_access_reminders: :environment do
    psu_libraries = Organization.find_by(pure_external_identifier: 'CAMPUS-UL')
    OpenAccessNotifier.new(psu_libraries.all_users).send_notifications
  end

  desc 'Send reminder emails about potential open access publications to all applicable users in the given organization'
  task :send_all_open_access_reminders_for_org, [:org_name] => :environment do |_task, args|
    org = Organization.find_by(pure_external_identifier: args[:org_name])
    if org
      OpenAccessNotifier.new(org.all_users).send_notifications
    else
      raise "Couldn't find an organization with Pure external identifier #{args[:org_name]}"
    end
  end

  desc 'Send reminder emails about potential open access publications to the first five applicable users in the given organization'
  task :send_first_five_open_access_reminders_for_org, [:org_name] => :environment do |_task, args|
    org = Organization.find_by(pure_external_identifier: args[:org_name])
    if org
      OpenAccessNotifier.new(org.all_users).send_notifications_with_cap(5)
    else
      raise "Couldn't find an organization with Pure external identifier #{args[:org_name]}"
    end
  end

  desc 'Send a test open access reminder email with fake data to the specified email address'
  task :test_open_access_reminder, [:address] => :environment do |_task, args|
    test_user = OpenStruct.new({ email: args[:address],
                                 name: 'Email Tester' })
    pub1 = OpenStruct.new({ title: 'Example Publication One', year: 2020, published_by: 'Journal One' })
    pub2 = OpenStruct.new({ title: 'Example Publication Two' })
    pub3 = OpenStruct.new({ title: 'Example Publication Three' })
    FacultyNotificationsMailer.open_access_reminder(test_user,
                                                    [pub1, pub2, pub3]).deliver_now
    $stdout.puts "Test open access reminder email sent to #{args[:address]}"
  end
end
