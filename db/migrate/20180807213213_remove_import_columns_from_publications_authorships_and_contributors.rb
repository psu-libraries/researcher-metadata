class RemoveImportColumnsFromPublicationsAuthorshipsAndContributors < ActiveRecord::Migration[5.2]
  def change
    remove_column :publications, :pure_uuid
    remove_column :publications, :activity_insight_identifier
    remove_column :publications, :pure_updated_at

    remove_column :authorships, :activity_insight_identifier
    remove_column :authorships, :pure_identifier

    remove_column :contributors, :activity_insight_identifier
    remove_column :contributors, :pure_identifier
  end
end
