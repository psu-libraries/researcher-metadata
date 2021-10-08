class AddUsageTrackingColumnsToAPITokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :total_requests, :integer, default: 0
    add_column :api_tokens, :last_used_at, :datetime
  end
end
