class CreatePresentations < ActiveRecord::Migration[5.2]
  def change
    create_table :presentations do |t|
      t.text :title, null: false
      t.string :activity_insight_identifier
      t.text :name
      t.string :organization
      t.string :location
      t.date :started_on
      t.date :ended_on
      t.string :type
      t.string :classification
      t.string :meet_type
      t.integer :attendance
      t.string :refereed
      t.text :abstract
      t.text :comment
      t.string :scope
      t.datetime :updated_by_user_at
      t.boolean :visible, default: false
      t.timestamps
    end
  end
end
