# frozen_string_literal: true

class ProfileManagementController < UserController
  layout :resolve_layout

  private

    def resolve_layout
      if action_name == 'show'
        'profile'
      else
        'manage_profile'
      end
    end
end
