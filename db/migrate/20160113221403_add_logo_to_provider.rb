class AddLogoToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :logo, :string
  end
end
