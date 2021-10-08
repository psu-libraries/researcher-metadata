# frozen_string_literal: true

class AddPureUpdatedAtTimestampToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :pure_updated_at, :datetime
  end
end
