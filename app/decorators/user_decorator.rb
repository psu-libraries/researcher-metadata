# frozen_string_literal: true

class UserDecorator < BaseDecorator
  attr_reader :impersonator

  def initialize(user:, impersonator: nil)
    @impersonator = impersonator
    super(user)
  end

  def masquerading?
    impersonator.present?
  end
end
