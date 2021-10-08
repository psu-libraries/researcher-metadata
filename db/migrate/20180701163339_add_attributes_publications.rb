class AddAttributesPublications < ActiveRecord::Migration[5.2]
  def change
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
  end
end
