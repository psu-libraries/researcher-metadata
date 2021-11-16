# frozen_string_literal: true

class DeputyAssignmentsController < ProfileManagementController
  def index
    load_index_assignments
    @new_deputy_assigment = NewDeputyAssignmentForm.new(primary: current_user)
  end

  def create
    @new_deputy_assigment = NewDeputyAssignmentForm.new(
      primary: current_user,
      deputy_webaccess_id: params.dig(:new_deputy_assignment_form, :deputy_webaccess_id)
    )
    if @new_deputy_assigment.save
      DeputyAssignmentsMailer
        .deputy_assignment_request(@new_deputy_assigment.deputy_assignment)
        .deliver_now

      redirect_to deputy_assignments_path, notice: t('.success')
    else
      load_index_assignments
      render :index
    end
  end

  def confirm
    @deputy_assignment = current_user.deputy_assignments.active.find(params[:id])
    @deputy_assignment.confirm!
    DeputyAssignmentsMailer
      .deputy_assignment_confirmation(@deputy_assignment)
      .deliver_now
    flash.notice = t('.success', name: @deputy_assignment.primary.name)
  rescue ActiveRecord::RecordInvalid
    flash.alert = t('.error')
  ensure
    redirect_to deputy_assignments_path
  end

  def destroy
    @deputy_assignment = DeputyAssignment.where(primary: current_user)
      .or(DeputyAssignment.where(deputy: current_user))
      .find(params[:id])

    # Generate (but don't send) email now, so we are guaranteed to have a
    # fully functioning DeputyAssignment object
    email = build_notification_email_for_destroy(@deputy_assignment)

    DeputyAssignmentDeleteService.call(deputy_assignment: @deputy_assignment)
    email.deliver_now
    flash.notice = t('.success')
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid
    flash.alert = t('.error')
  ensure
    redirect_to deputy_assignments_path
  end

  private

    def load_index_assignments
      @primary_assignments = current_user
        .primary_assignments
        .active
        .eager_load(:deputy)
        .order('users.last_name' => :asc)

      active_deputy_assignments = current_user
        .deputy_assignments
        .active
        .eager_load(:primary)
        .order('users.last_name' => :asc)

      # Already sorted alphabetically, move any pending to the top
      pending, confirmed = active_deputy_assignments
        .partition(&:pending?)

      @deputy_assignments = pending + confirmed
    end

    def build_notification_email_for_destroy(deputy_assignment)
      mailer_method = if current_user == deputy_assignment.primary
                        :deputy_status_revoked
                      elsif deputy_assignment.confirmed?
                        :deputy_status_ended
                      else
                        :deputy_assignment_declination
                      end

      # `send` is confusing here, we are not sending an email, we are
      # dynamically calling the method determined above
      DeputyAssignmentsMailer.send(mailer_method, deputy_assignment)
    end
end
