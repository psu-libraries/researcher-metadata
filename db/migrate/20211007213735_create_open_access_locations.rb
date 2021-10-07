class CreateOpenAccessLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :open_access_locations do |t|
      t.integer :publication_id
      t.string :host_type
      t.boolean :is_best
      t.string :license
      t.date :oa_date
      t.string :source
      t.datetime :source_updated_at
      t.string :url
      t.string :landing_page_url
      t.string :pdf_url
      t.string :version
      t.timestamps null: false
    end

    add_index :open_access_locations, :publication_id

    add_foreign_key :open_access_locations,
                    :publications,
                    name: :open_access_locations_publication_id_fk,
                    on_delete: :cascade
  end
end
