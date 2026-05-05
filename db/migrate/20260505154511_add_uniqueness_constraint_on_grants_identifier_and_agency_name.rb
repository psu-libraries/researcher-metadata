class AddUniquenessConstraintOnGrantsIdentifierAndAgencyName < ActiveRecord::Migration[7.2]
  def change
    add_index :grants, [:identifier, :agency_name], unique: true
  end
end
