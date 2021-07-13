namespace :email_notifications do
  desc 'Send reminder emails about potential open access publications to all applicable users'
  task send_all_open_access_reminders: :environment do
    OpenAccessNotifier.new.send_notifications
  end

  desc 'Send reminder emails about potential open access publications only to applicable users in the Penn State University Libraries'
  task send_library_open_access_reminders: :environment do
    psu_libraries = Organization.find_by(pure_external_identifier: 'CAMPUS-UL')
    OpenAccessNotifier.new(psu_libraries.all_users).send_notifications
  end

  desc 'Send reminder emails about potential open access publications to all applicable users in the given organization'
  task :send_all_access_reminders_for_org, [:org_name] => :environment do |task, args|
    org = Organization.find_by(pure_external_identifier: args[:org_name])
    if org
      OpenAccessNotifier.new(org.all_users).send_notifications
    else
      raise RuntimeError.new("Couldn't find an organization with Pure external identifier #{args[:org_name]}")
    end
  end

  desc 'Send reminder emails about potential open access publications to the first five applicable users in the given organization'
  task :send_first_five_open_access_reminders_for_org, [:org_name] => :environment do |task, args|
    org = Organization.find_by(pure_external_identifier: args[:org_name])
    if org
      OpenAccessNotifier.new(org.all_users).send_first_five_notifications
    else
      raise RuntimeError.new("Couldn't find an organization with Pure external identifier #{args[:org_name]}")
    end
  end

  desc 'Send a test open access reminder email with fake data to the specified email address'
  task :test_open_access_reminder, [:address] => :environment do |task, args|
    test_user = OpenStruct.new({email: args[:address],
                                name: 'Email Tester'})
    pub1 = OpenStruct.new({title: "Example Publication One"})
    pub2 = OpenStruct.new({title: "Example Publication Two"})
    pub3 = OpenStruct.new({title: "Example Publication Three"})
    old_fake_pubs = [pub1, pub2]
    new_fake_pubs = [pub3]
    FacultyNotificationsMailer.open_access_reminder(test_user,
                                                    old_fake_pubs,
                                                    new_fake_pubs).deliver_now
    STDOUT.puts "Test open access reminder email sent to #{args[:address]}"
  end
end
