# frozen_string_literal: true

class DeputyAssignmentsMailer < ApplicationMailer
  def deputy_assignment_confirmation(deputy_assignment)
    @primary = UserProfile.new(deputy_assignment.primary)
    @deputy = deputy_assignment.deputy
    @deputy_url = deputy_assignments_url
    mail to: @primary.email,
         subject: 'PSU Researcher Metadata Database - Proxy Request Confirmed',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def deputy_assignment_declination(deputy_assignment)
    @primary = UserProfile.new(deputy_assignment.primary)
    @deputy = deputy_assignment.deputy
    mail to: @primary.email,
         subject: 'PSU Researcher Metadata Database - Proxy Request Declined',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def deputy_assignment_request(deputy_assignment)
    @primary = deputy_assignment.primary
    @deputy = UserProfile.new(deputy_assignment.deputy)
    @deputy_url = deputy_assignments_url
    mail to: @deputy.email,
         subject: 'PSU Researcher Metadata Database - Proxy Assignment Request',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def deputy_status_ended(deputy_assignment)
    @primary = UserProfile.new(deputy_assignment.primary)
    @deputy = deputy_assignment.deputy
    mail to: @primary.email,
         subject: 'PSU Researcher Metadata Database - Proxy Status Ended',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end

  def deputy_status_revoked(deputy_assignment)
    @primary = deputy_assignment.primary
    @deputy = UserProfile.new(deputy_assignment.deputy)
    mail to: @deputy.email,
         subject: 'PSU Researcher Metadata Database - Proxy Status Revoked',
         from: 'openaccess@psu.edu',
         reply_to: 'openaccess@psu.edu'
  end
end
