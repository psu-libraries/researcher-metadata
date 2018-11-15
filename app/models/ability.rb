class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.is_admin
        can :manage, :all
      elsif user.managed_organizations.any?
        can :access, :rails_admin
        can :dashboard, :all
        can :index, User, user.managed_users.distinct do |u|
        end
        can :edit, User, user.managed_users.distinct do |u|
          user.managed_users.include?(u)
        end
      end
    end
  end
end
