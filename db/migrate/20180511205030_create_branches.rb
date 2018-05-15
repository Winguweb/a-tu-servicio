class CreateBranches < ActiveRecord::Migration[5.2]
  def change
    enable_extension "postgis"
    create_table :branches do |t|
      t.string :name
      t.text :address
      t.geometry :georeference
      t.string :town
      t.integer :provider_id, null: false, index: true
      t.integer :state_id, null: false, index: true
    end
  end
end
