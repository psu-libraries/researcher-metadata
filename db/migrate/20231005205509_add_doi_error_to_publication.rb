class AddDOIErrorToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :doi_error, :boolean
  end
end
