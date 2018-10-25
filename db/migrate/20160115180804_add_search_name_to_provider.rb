class AddSearchNameToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :search_name, :string
  end
end
