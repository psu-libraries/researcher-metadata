class ProfileManagementController < UserController
  layout :resolve_layout
  before_action :authenticate!

  private

  def resolve_layout
    if action_name == 'show'
      'profile'
    else
      'manage_profile'
    end
  end
end