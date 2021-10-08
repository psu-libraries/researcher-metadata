# frozen_string_literal: true

class CreateJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :journals do |t|
      t.string :pure_uuid
      t.text :title, null: false
      t.timestamps null: false
    end
  end
end
