class ChangeRankColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :publication_taggings, :rank, :float
  end
end
