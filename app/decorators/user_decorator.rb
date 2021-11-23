# frozen_string_literal: true

class UserDecorator < BaseDecorator
  def initialize(user:, impersonator: nil)
    @impersonator = impersonator
    super(user)
  end

  def impersonator
    @impersonator ||= NullUser.new
  end
  alias :deputy :impersonator

  def masquerading?
    impersonator.present?
  end
end
