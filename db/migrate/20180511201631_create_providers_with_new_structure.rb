class CreateProvidersWithNewStructure < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :address
      t.string :subnet
      t.string :abbreviation
      t.string :website
      t.string :email
      t.integer :affiliations
      t.integer :financed_affiliations
      t.text :communication_services
      t.text :logo_url
      t.integer :logo_url
      t.boolean :is_private
      t.boolean :show
      t.boolean :featured
      t.integer :state_id, index: true
    end
    add_index :providers, :name
  end
end
