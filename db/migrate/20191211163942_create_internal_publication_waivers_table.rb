# frozen_string_literal: true

class CreateInternalPublicationWaiversTable < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_publication_waivers do |t|
      t.integer :authorship_id, null: false
      t.text :reason_for_waiver
      t.timestamps null: false
    end

    add_index :internal_publication_waivers, :authorship_id
    add_foreign_key :internal_publication_waivers, :authorships, name: :internal_publication_waivers_authorship_id_fk
  end
end
