# frozen_string_literal: true

class DeputyAssignmentComponent < ViewComponent::Base
  def initialize(deputy_assignment:, current_user:)
    @deputy_assignment = deputy_assignment
    @current_user = current_user
  end

end
