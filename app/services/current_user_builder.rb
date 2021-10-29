# frozen_string_literal: true

class CurrentUserBuilder
  def self.call(current_user:, current_session:)
    return NullUser.new if current_user.nil?

    if current_user.admin? && current_session.key?(:pretend_user_id)
      UserDecorator.new(
        user: User.find(current_session[:pretend_user_id]),
        impersonator: current_user
      )
    else
      UserDecorator.new(user: current_user)
    end
  end
end
