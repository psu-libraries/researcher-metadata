class CreateSourcePublications < ActiveRecord::Migration[7.2]
  def change
    create_table :source_publications do |t|
      t.string :source_identifier, null: false
      t.string :status
      t.references :import, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
