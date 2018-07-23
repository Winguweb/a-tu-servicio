class CreateSatisfactions < ActiveRecord::Migration[5.2]
  def change
    create_table :satisfactions do |t|
      t.string :name
      t.decimal :percentage, precision: 5, scale: 4
      t.integer :provider_id, null: false, index: true
    end
  end
end
