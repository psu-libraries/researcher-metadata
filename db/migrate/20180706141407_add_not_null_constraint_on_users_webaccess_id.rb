# frozen_string_literal: true

class AddNotNullConstraintOnUsersWebaccessId < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :webaccess_id, false
  end
end
