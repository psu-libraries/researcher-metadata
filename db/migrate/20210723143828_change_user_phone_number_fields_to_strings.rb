class ChangeUserPhoneNumberFieldsToStrings < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :ai_office_area_code, :string
    change_column :users, :ai_office_phone_1, :string
    change_column :users, :ai_office_phone_2, :string
    change_column :users, :ai_fax_area_code, :string
    change_column :users, :ai_fax_1, :string
    change_column :users, :ai_fax_2, :string
  end
end
