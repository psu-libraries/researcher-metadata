class CreateActivityInsightOaFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :activity_insight_oa_files do |t|
      t.string :location
      t.string :checksum
      t.bigint :publication_id, null: false

      t.timestamps
    end

    add_index(:activity_insight_oa_files, :publication_id, :unique => true)
    add_foreign_key :activity_insight_oa_files, 
                    :publications, 
                    name: :activity_insight_oa_files_publication_id_fk,
                    on_delete: :cascade
  end
end
