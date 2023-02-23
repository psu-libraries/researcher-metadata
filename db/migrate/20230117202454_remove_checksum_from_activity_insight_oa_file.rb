class RemoveChecksumFromActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def up
    remove_column :activity_insight_oa_files, :checksum, :string
  end

  def down
    add_column :activity_insight_oa_files, :checksum, :string
  end
end
