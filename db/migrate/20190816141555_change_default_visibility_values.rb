# frozen_string_literal: true

class ChangeDefaultVisibilityValues < ActiveRecord::Migration[5.2]
  def change
    change_column_default :performances, :visible, from: false, to: true
    change_column_default :presentations, :visible, from: false, to: true
    change_column_default :publications, :visible, from: false, to: true
    change_column_default :users, :show_all_publications, from: false, to: true
    change_column_default :organizations, :visible, from: nil, to: true
  end
end
