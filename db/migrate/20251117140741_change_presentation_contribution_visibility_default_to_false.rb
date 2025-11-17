class ChangePresentationContributionVisibilityDefaultToFalse < ActiveRecord::Migration[7.2]
  def change
    change_column_default :presentation_contributions, :visible_in_profile, from: true, to: false
  end
end
