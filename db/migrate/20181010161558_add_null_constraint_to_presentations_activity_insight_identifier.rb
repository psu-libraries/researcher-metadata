class AddNullConstraintToPresentationsActivityInsightIdentifier < ActiveRecord::Migration[5.2]
  def change
    change_column_null :presentations, :activity_insight_identifier, false
  end
end
