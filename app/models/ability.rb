class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.is_admin
      can :access, :rails_admin
      can :dashboard, :all
      can :manage, :all
    end
  end
end