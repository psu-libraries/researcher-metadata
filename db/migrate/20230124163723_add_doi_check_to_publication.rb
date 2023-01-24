class AddDOICheckToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :doi_check, :boolean 
  end
end
