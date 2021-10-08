# frozen_string_literal: true

class CreateScholarsphereFileUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :scholarsphere_file_uploads do |t|
      t.references :authorship, foreign_key: true
      t.string :file
      t.timestamps null: false
    end
  end
end
