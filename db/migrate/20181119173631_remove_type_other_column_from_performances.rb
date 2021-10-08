# frozen_string_literal: true

class RemoveTypeOtherColumnFromPerformances < ActiveRecord::Migration[5.2]
  def change
    remove_column :performances, :type_other
  end
end
