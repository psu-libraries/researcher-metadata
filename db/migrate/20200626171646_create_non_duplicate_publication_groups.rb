# frozen_string_literal: true

class CreateNonDuplicatePublicationGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :non_duplicate_publication_groups do |t|
      t.timestamps null: false
    end
  end
end
