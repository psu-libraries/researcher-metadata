# frozen_string_literal: true

class DeputyAssignmentsMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/deputy_assignments_mailer/deputy_assignment_request
  def deputy_assignment_request
    DeputyAssignmentsMailer.deputy_assignment_request(fake_deputy_assignment)
  end

  # Accessible from http://localhost:3000/rails/mailers/deputy_assignments_mailer/deputy_assignment_confirmation
  def deputy_assignment_confirmation
    DeputyAssignmentsMailer.deputy_assignment_confirmation(fake_deputy_assignment)
  end

  # Accessible from http://localhost:3000/rails/mailers/deputy_assignments_mailer/deputy_assignment_declination
  def deputy_assignment_declination
    DeputyAssignmentsMailer.deputy_assignment_declination(fake_deputy_assignment)
  end

  private

    def fake_deputy_assignment
      OpenStruct.new({
                       primary: OpenStruct.new({ name: 'Primary Jones', webaccess_id: 'pj123' }),
                       deputy: OpenStruct.new({ name: 'Deputy Smith', webaccess_id: 'ds456' })
                     })
    end
end
