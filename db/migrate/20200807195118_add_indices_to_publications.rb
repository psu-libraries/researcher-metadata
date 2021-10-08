# frozen_string_literal: true

class AddIndicesToPublications < ActiveRecord::Migration[5.2]
  def up
    add_index :publications, :published_on
    execute(%{CREATE INDEX index_publications_on_published_on_year ON publications USING btree (EXTRACT(YEAR FROM published_on));})
  end

  def down
    remove_index :publications, :published_on
    remove_index :publications, name: :index_publications_on_published_on_year
  end
end
