class AddJournalAssignmentOverriddenToPublications < ActiveRecord::Migration[8.1]
  def change
    add_column :publications, :journal_assignment_overridden, :boolean, default: false, null: false
  end
end
