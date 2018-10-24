class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.text :name, null: false
      t.boolean :visible
      t.string :pure_uuid
      t.string :pure_external_identifier
      t.string :type
      t.integer :parent_id
      t.timestamps
    end

    add_index :organizations, :pure_uuid, unique: true
    add_index :organizations, :parent_id
    add_foreign_key :organizations,
                    :organizations,
                    column: :parent_id,
                    name: :organizations_parent_id_fk,
                    on_delete: :restrict
  end
end
