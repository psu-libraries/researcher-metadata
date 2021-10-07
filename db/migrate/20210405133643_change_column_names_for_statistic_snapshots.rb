class ChangeColumnNamesForStatisticSnapshots < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :statistics_snapshots, :total_publication_count, :total_article_count
    rename_column :statistics_snapshots, :open_access_publication_count, :open_access_article_count
  end

  def self.down
    rename_column :statistics_snapshots, :total_article_count, :total_publication_count
    rename_column :statistics_snapshots, :open_access_article_count, :open_access_publication_count
  end
end
