# frozen_string_literal: true

class DeputyAssignmentDeleteService
  def self.call(deputy_assignment:)
    return unless deputy_assignment.active?

    if deputy_assignment.active? && deputy_assignment.pending?
      deputy_assignment.destroy!
    else
      deputy_assignment.deactivate!
    end
  end
end
