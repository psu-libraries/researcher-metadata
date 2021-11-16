# frozen_string_literal: true

# @abstract A builder service that returns a UserDecorator as the current_user for a session.  The service determines if
# the user who is presently authenticated is impersonating another user or not. If they are, it checks to see if they
# are allowed to, and returns the appropriate decorator.

class CurrentUserBuilder
  # @param current_user [User, nil]
  # @param current_session [Hash]
  # @return UserDecorator
  def self.call(current_user:, current_session:)
    return NullUser.new if current_user.nil?
    return UserDecorator.new(user: current_user) unless current_session.key?(MasqueradingBehaviors::SESSION_ID)

    user = User.find(current_session[MasqueradingBehaviors::SESSION_ID]) || NullUser.new

    if current_user.admin? || user.available_deputy?(current_user)
      UserDecorator.new(
        user: user,
        impersonator: current_user
      )
    else
      UserDecorator.new(user: current_user)
    end
  end
end
