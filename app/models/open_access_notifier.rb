class OpenAccessNotifier
  def initialize(users = nil)
    @users = users
  end

  def send_notifications
    users.each do |u|
      user_profile = UserProfile.new(u)
      FacultyNotificationsMailer.open_access_reminder(user_profile, u.potential_open_access_publications).deliver_now

      ActiveRecord::Base.transaction do
        u.record_open_access_notification
        u.potential_open_access_publications.each do |p|
          p.authorships.find_by(user: u).record_open_access_notification
        end
      end
    end
  end

  private

  def users
    @users || User.needs_open_access_notification
  end
end
