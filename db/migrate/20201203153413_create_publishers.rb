class CreatePublishers < ActiveRecord::Migration[5.2]
  def change
    create_table :publishers do |t|
      t.string :pure_uuid
      t.text :name, null: false
      t.timestamps null: false
    end
  end
end
