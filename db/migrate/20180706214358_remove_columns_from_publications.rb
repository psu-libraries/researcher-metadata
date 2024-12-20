class RemoveColumnsFromPublications < ActiveRecord::Migration[5.2]
  def up
    remove_column :publications, :title
    remove_column :publications, :activity_insight_identifier
    remove_column :publications, :activity_insight_updated_at
    remove_column :publications, :characteristic
    remove_column :publications, :secondary_title
    remove_column :publications, :source
    remove_column :publications, :status
    remove_column :publications, :volume
    remove_column :publications, :issue
    remove_column :publications, :edition
    remove_column :publications, :page_range
    remove_column :publications, :url
    remove_column :publications, :isbn_issn
    remove_column :publications, :abstract
    remove_column :publications, :published_at
  end

  def down
    add_column :publications, :title, :string
    add_column :publications, :activity_insight_identifier, :string
    add_column :publications, :activity_insight_updated_at, :datetime
    add_column :publications, :characteristic, :string
    add_column :publications, :secondary_title, :text
    add_column :publications, :source, :string
    add_column :publications, :status, :string
    add_column :publications, :volume, :string
    add_column :publications, :issue, :string
    add_column :publications, :edition, :string
    add_column :publications, :page_range, :string
    add_column :publications, :url, :text
    add_column :publications, :isbn_issn, :string
    add_column :publications, :abstract, :text
    add_column :publications, :published_at, :datetime

    add_index :publications, :activity_insight_identifier
  end
end
