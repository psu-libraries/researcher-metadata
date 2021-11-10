# frozen_string_literal: true

class DeputyAssignmentComponent < ViewComponent::Base
  def initialize(deputy_assignment:, current_user:)
    @deputy_assignment = deputy_assignment
    @current_user = current_user
  end

  delegate :primary,
           :deputy,
           :confirmed?,
           :pending?,
           to: :deputy_assignment

  delegate :name,
           :webaccess_id,
           to: :other_user

  def current_user_is_primary?
    current_user == primary
  end

  def current_user_is_deputy?
    !current_user_is_primary?
  end

  def other_user
    current_user_is_primary? ? deputy : primary
  end

  def root_class
    classes = %w[deputy-assignment]
    classes << 'deputy-assignment--action-required' if current_user_is_deputy? && pending?
    classes.join(' ')
  end

  def delete_text
    key = if current_user_is_primary? then 'delete_as_primary'
          elsif confirmed? then 'delete_as_deputy'
          else 'delete_as_deputy_unconfirmed'
          end
    i18n(key)
  end

  def delete_class
    classes = %w[btn btn-sm]
    classes << if current_user_is_deputy? && pending?
                 'btn-outline-secondary'
               else
                 'btn-outline-danger'
               end
    classes
  end

  private

    attr_reader :deputy_assignment,
                :current_user

    def i18n(key)
      I18n.t("view_component.#{self.class.name.underscore}.#{key}")
    end
end
