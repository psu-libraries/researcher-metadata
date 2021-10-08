class CreatePerformanceScreenings < ActiveRecord::Migration[5.2]
  def change
    create_table :performance_screenings do |t|
      t.integer :performance_id, null: false
      t.string :screening_type
      t.string :name
      t.string :location

      t.timestamps
    end

    add_index :performance_screenings, :performance_id

    add_foreign_key :performance_screenings, :performances, on_delete: :cascade
  end
end
