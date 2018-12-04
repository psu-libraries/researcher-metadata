class AddContributionStudentLevelAndRoleOtherToUserPerformances < ActiveRecord::Migration[5.2]
  def change
    add_column :user_performances, :contribution, :string
    add_column :user_performances, :student_level, :string
    add_column :user_performances, :role_other, :string
  end
end
