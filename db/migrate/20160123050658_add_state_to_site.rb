class AddStateToSite < ActiveRecord::Migration[5.2]
  def change
    change_table :sites do |t|
      t.references :state
    end
  end
end
