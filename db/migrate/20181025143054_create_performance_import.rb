class CreatePerformanceImport < ActiveRecord::Migration[5.2]
  def change
    create_table :performance_imports do |t|
      t.integer :performance_id, null: false
      t.integer :activity_insight_id, null: false

      t.timestamps
    end

    add_index :performance_imports, :activity_insight_id, unique: true
    add_index :performance_imports, :performance_id

    add_foreign_key :performance_imports, :performances, on_delete: :cascade
  end
end
