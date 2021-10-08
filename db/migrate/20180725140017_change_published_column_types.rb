class ChangePublishedColumnTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :publication_imports, :published_at, :date
    change_column :publications, :published_at, :date

    rename_column :publication_imports, :published_at, :published_on
    rename_column :publications, :published_at, :published_on
  end
end
