# frozen_string_literal: true

class AddIndexesOnPublications < ActiveRecord::Migration[5.2]
  def change
    add_index :publications, :volume
    add_index :publications, :issue
  end
end
