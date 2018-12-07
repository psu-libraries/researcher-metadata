class AddContactAndBioInformationColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :ai_title
      t.string :ai_rank
      t.string :ai_endowed_title
      t.string :orcid_identifier
      t.string :ai_alt_name
      t.string :ai_building
      t.string :ai_room_number
      t.integer :ai_office_area_code
      t.integer :ai_office_phone_1
      t.integer :ai_office_phone_2
      t.integer :ai_fax_area_code
      t.integer :ai_fax_1
      t.integer :ai_fax_2
      t.text :ai_website
      t.text :ai_bio
      t.text :ai_teaching_interests
      t.text :ai_research_interests
    end
  end
end
