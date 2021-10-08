# frozen_string_literal: true

class AddPureIdentifierToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :pure_identifier, :string
    add_index :authorships, :pure_identifier, unique: true
  end
end
