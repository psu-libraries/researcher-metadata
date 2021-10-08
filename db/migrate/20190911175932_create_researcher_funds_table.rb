# frozen_string_literal: true

class CreateResearcherFundsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :researcher_funds do |t|
      t.integer :grant_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :researcher_funds, :grant_id
    add_index :researcher_funds, :user_id

    add_foreign_key :researcher_funds, :grants, name: :research_funds_grant_id_fk, on_delete: :cascade
    add_foreign_key :researcher_funds, :users, name: :research_funds_user_id_fk, on_delete: :cascade
  end
end
