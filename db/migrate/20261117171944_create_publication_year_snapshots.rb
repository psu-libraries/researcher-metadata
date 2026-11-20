class CreatePublicationYearSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :publication_year_snapshots do |t|
      t.integer :publication_year
      t.integer :total_article_count
      t.integer :open_access_article_count
      t.references :statistics_snapshot, null: false, foreign_key: true, index: false

      t.timestamps
    end
    add_index :publication_year_snapshots,
              [:statistics_snapshot_id, :publication_year],
              unique: true
  end
end
