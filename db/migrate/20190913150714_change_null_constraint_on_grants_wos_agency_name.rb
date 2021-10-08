# frozen_string_literal: true

class ChangeNullConstraintOnGrantsWOSAgencyName < ActiveRecord::Migration[5.2]
  def change
    change_column_null :grants, :wos_agency_name, true
  end
end
