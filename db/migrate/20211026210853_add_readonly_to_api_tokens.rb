class AddReadonlyToAPITokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :write_access, :boolean, default: false
  end
end
