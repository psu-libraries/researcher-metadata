# frozen_string_literal: true

class ChangeContractImportColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :contract_imports, :activity_insight_id, :bigint
  end
end
