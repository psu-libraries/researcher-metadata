# frozen_string_literal: true

class CreateEducationHistoryItems < ActiveRecord::Migration[5.2]
  def change
    create_table :education_history_items do |t|
      t.integer :user_id, null: false
      t.string :activity_insight_identifier
      t.string :degree
      t.text :explanation_of_other_degree
      t.string :is_honorary_degree
      t.string :is_highest_degree_earned
      t.text :institution
      t.text :school
      t.text :location_of_institution
      t.text :emphasis_or_major
      t.text :supporting_areas_of_emphasis
      t.text :dissertation_or_thesis_title
      t.text :honor_or_distinction
      t.text :description
      t.text :comments
      t.integer :start_year
      t.integer :end_year
      t.timestamps
    end

    add_index :education_history_items, :user_id

    add_foreign_key :education_history_items, :users, on_delete: :cascade
  end
end
