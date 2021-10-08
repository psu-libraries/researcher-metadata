class AddErrorMessageToImportErrorLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :importer_error_logs, :error_message, :text, null: false
  end
end
