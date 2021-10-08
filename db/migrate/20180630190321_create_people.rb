# frozen_string_literal: true

class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.string :activity_insight_identifier
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :institution
      t.string :title

      t.timestamps
    end
  end
end
