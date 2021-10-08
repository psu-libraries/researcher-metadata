# frozen_string_literal: true

class CreateEmailErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :email_errors do |t|
      t.integer :user_id, null: false
      t.text :message
      t.timestamps null: false
    end

    add_index :email_errors, :user_id

    add_foreign_key :email_errors, :users, name: :email_errors_user_id_fk
  end
end
