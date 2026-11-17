class AddUniversalAccessToAPIToken < ActiveRecord::Migration[8.1]
  def change
    add_column :api_tokens, :universal_access, :boolean, default: false, null: false
  end
end
