class CreateProviderMaximumsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_maximums do |t|
      t.decimal :tickets
      t.decimal :waiting_time
      t.integer :affiliates
      t.decimal :personnel

      t.timestamps null: false
    end
  end
end
