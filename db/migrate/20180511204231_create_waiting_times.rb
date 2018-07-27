class CreateWaitingTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :waiting_times do |t|
      t.string :name
      t.decimal :days, precision: 4, scale: 2
      t.integer :provider_id, null: false, index: true
    end
  end
end
