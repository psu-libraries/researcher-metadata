# frozen_string_literal: true

class ChangePublicationsForeignKeyOnContributors < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :contributors, :publications
    add_foreign_key :contributors, :publications, on_delete: :cascade
  end
end
