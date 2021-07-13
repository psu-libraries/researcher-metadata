class OpenAccessNotifier
  def initialize(users=User)
    @users = users
  end

  def send_notifications
    users.each do |u|
      send_notification_to_user(u)
    end
  end

  def send_first_five_notifications
    first_five_users.each do |u|
      send_notification_to_user(u)
    end
  end

  private

  def users
    @users.needs_open_access_notification
  end

  def first_five_users
    users.first(5)
  end

  def send_notification_to_user(user)
    user_profile = UserProfile.new(user)
    begin
      FacultyNotificationsMailer.open_access_reminder(user_profile,
                                                      user.old_potential_open_access_publications,
                                                      user.new_potential_open_access_publications).deliver_now

      ActiveRecord::Base.transaction do
        user.record_open_access_notification
        pubs = user.old_potential_open_access_publications + user.new_potential_open_access_publications
        pubs.each do |p|
          p.authorships.find_by(user: user).record_open_access_notification
        end
      end
    rescue Net::SMTPFatalError => e
      EmailError.create!(message: e.message, user: user)
    end
  end
end
