# frozen_string_literal: true

class RemoveNullConstraintOnPresentationTitle < ActiveRecord::Migration[5.2]
  def change
    change_column_null :presentations, :title, true
  end
end
