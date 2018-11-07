class CreatePerformances < ActiveRecord::Migration[5.2]
  def change
    create_table :performances do |t|
      t.text :title, null: false
      t.bigint :activity_insight_id, null: false
      t.string :performance_type
      t.text :type_other
      t.text :sponsor
      t.text :description
      t.text :group_name
      t.text :location
      t.string :delivery_type
      t.string :scope
      t.date :start_on
      t.date :end_on
      t.datetime :updated_by_user_at
      t.timestamps
    end

    add_index :performances, :activity_insight_id, unique: true
  end
end
