# frozen_string_literal: true

class CreatePresentationContributions < ActiveRecord::Migration[5.2]
  def change
    create_table :presentation_contributions do |t|
      t.integer :user_id, null: false
      t.integer :presentation_id, null: false
      t.integer :position
      t.string :activity_insight_identifier
      t.string :role
      t.timestamps
    end

    add_index :presentation_contributions, :user_id
    add_index :presentation_contributions, :presentation_id
    add_index :presentation_contributions, :activity_insight_identifier, unique: true

    add_foreign_key :presentation_contributions, :users, name: :presentation_contributions_user_id_fk, on_delete: :cascade
    add_foreign_key :presentation_contributions, :presentations, name: :presentation_contributions_presentation_id_fk, on_delete: :cascade
  end
end
