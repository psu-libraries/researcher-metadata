class AddUniquenessToEtdsIndices < ActiveRecord::Migration[5.2]
  def up
    remove_index :etds, :webaccess_id
    remove_index :etds, :external_identifier
    add_index :etds, :webaccess_id, unique: true
    add_index :etds, :external_identifier, unique: true
  end

  def down
    remove_index :etds, :webaccess_id
    remove_index :etds, :external_identifier
    add_index :etds, :webaccess_id, unique: false
    add_index :etds, :external_identifier, unique: false
  end
end
