class CreateCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :costs do |t|
      t.string :name
      t.decimal :amount, precision: 10, scale: 2
      t.integer :provider_id, null: false, index: true
    end
  end
end
