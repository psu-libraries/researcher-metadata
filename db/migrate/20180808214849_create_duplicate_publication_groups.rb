# frozen_string_literal: true

class CreateDuplicatePublicationGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :duplicate_publication_groups do |t|
      t.text :title
      t.text :journal
      t.string :issue
      t.string :volume
      t.timestamps
    end
  end
end
