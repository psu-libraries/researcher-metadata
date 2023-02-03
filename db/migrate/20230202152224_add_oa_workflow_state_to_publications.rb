class AddOaWorkflowStateToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :oa_workflow_state, :string
  end
end
