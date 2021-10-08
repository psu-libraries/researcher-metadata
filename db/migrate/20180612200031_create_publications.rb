# frozen_string_literal: true

class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.timestamps
    end
  end
end
