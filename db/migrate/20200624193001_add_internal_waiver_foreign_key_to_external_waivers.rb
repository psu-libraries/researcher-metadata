class AddInternalWaiverForeignKeyToExternalWaivers < ActiveRecord::Migration[5.2]
  def change
    add_column :external_publication_waivers, :internal_publication_waiver_id, :integer
    add_foreign_key :external_publication_waivers, :internal_publication_waivers, name: :external_publication_waivers_internal_publication_waiver_id_fk
    add_index :external_publication_waivers, :internal_publication_waiver_id, name: :index_external_waivers_on_internal_waiver_id
  end
end
