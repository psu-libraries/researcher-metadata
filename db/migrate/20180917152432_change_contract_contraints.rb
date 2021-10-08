# frozen_string_literal: true

class ChangeContractContraints < ActiveRecord::Migration[5.2]
  def change
    change_column_null :contracts, :award_start_on, true
    change_column_null :contracts, :award_end_on, true
  end
end
