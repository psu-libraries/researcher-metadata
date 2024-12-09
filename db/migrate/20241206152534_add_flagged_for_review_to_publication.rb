class AddFlaggedForReviewToPublication < ActiveRecord::Migration[7.2]
  def change
    add_column :publications, :flagged_for_review, :boolean
  end
end
