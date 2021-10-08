class RemoveUnneededColumnsFromDuplicatePublicationGroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :duplicate_publication_groups, :title
    remove_column :duplicate_publication_groups, :journal
    remove_column :duplicate_publication_groups, :issue
    remove_column :duplicate_publication_groups, :volume
  end
end
