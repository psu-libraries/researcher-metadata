# frozen_string_literal: true

class AddOrcidAccessTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :orcid_access_token, :string
  end
end
