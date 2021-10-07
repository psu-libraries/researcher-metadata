class AddFieldsToPublications < ActiveRecord::Migration[5.2]
  def change
    change_table :publications do |t|
      t.text 'title', null: false
      t.string 'type', null: false
      t.text 'journal_title'
      t.text 'publisher'
      t.text 'secondary_title'
      t.string 'status'
      t.string 'volume'
      t.string 'issue'
      t.string 'edition'
      t.string 'page_range'
      t.text 'url'
      t.string 'isbn'
      t.string 'issn'
      t.string 'doi'
      t.text 'abstract'
      t.boolean 'authors_et_al'
      t.datetime 'published_at'
      t.text 'outside_contributors'
    end
  end
end
