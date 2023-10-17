class AddActivityInsightOAFileIdToScholarsphereWorkDeposits < ActiveRecord::Migration[6.1]
  def change
    add_column :scholarsphere_work_deposits, :activity_insight_oa_file_id, :integer
  end
end
