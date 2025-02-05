class CreateImports < ActiveRecord::Migration[7.2]
  def change
    create_table :imports do |t|
      t.string :source, null: false
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
