class CreateSpecialities < ActiveRecord::Migration[5.2]
  def change
    create_table :specialities do |t|
      t.string :name
      t.integer :professionals_count
      t.integer :provider_id, null: false, index: true
    end
  end
end
