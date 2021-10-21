# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def mark_as_updated_by_user
    # It's up to subclasses to implement this if applicable.
  end

  def self.to_enum_hash(arr)
    arr
      .map { |sym| [sym.to_sym, sym.to_s] }
      .to_h
  end
end
