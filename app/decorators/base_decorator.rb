# frozen_string_literal: true

# @abstract A base class for all our decorators that includes methods needed to make things work.

class BaseDecorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def to_model
    __getobj__
  end

  # @note Ensures that type checks return the expected classes. This was causing ActiveRecord.where and .find_by
  # operations not to work.
  def is_a?(klass)
    __getobj__.is_a?(klass)
  end
end
