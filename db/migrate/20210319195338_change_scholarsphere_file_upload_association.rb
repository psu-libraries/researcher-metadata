class ChangeScholarsphereFileUploadAssociation < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :scholarsphere_file_uploads, :authorships
    remove_index :scholarsphere_file_uploads, :authorship_id
    remove_column :scholarsphere_file_uploads, :authorship_id

    add_column :scholarsphere_file_uploads, :scholarsphere_work_deposit_id, :integer
    add_index :scholarsphere_file_uploads, :scholarsphere_work_deposit_id, name: :scholarsphere_file_uploads_on_deposit_id
    add_foreign_key :scholarsphere_file_uploads, :scholarsphere_work_deposits, name: :scholarsphere_file_uploads_deposit_id_fk
  end

  def down
    remove_foreign_key :scholarsphere_file_uploads, :scholarsphere_work_deposits
    remove_index :scholarsphere_file_uploads, :scholarsphere_work_deposit_id
    remove_column :scholarsphere_file_uploads, :scholarsphere_work_deposit_id

    add_column :scholarsphere_file_uploads, :authorship_id, :integer
    add_index :scholarsphere_file_uploads, :authorship_id
    add_foreign_key :scholarsphere_file_uploads, :authorships, name: :scholarsphere_file_uploads_authorship_id_fk
  end
end
