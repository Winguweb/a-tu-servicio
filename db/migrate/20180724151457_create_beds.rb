class CreateBeds < ActiveRecord::Migration[5.2]
  def change
    create_table :beds do |t|
      t.string :area
      t.integer :quantity
      t.integer :branch_id, null: false
    end
  end
end
