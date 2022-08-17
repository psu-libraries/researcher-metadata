class RemoveAiRankAndAiEndowedTitleFromUsers < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :ai_rank, :string
    remove_column :users, :ai_endowed_title, :string
  end

  def down
    add_column :users, :ai_rank, :string
    add_column :users, :ai_endowed_title, :string
  end
end
