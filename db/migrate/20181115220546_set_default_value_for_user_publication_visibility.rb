# frozen_string_literal: true

class SetDefaultValueForUserPublicationVisibility < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :show_all_publications, false
  end
end
