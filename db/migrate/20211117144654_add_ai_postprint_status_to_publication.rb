class AddAiPostprintStatusToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :activity_insight_postprint_status, :string
  end
end
