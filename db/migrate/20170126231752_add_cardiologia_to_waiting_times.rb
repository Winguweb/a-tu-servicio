class AddCardiologiaToWaitingTimes < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :providers, :tiempo_espera_cardiologia
    	add_column :providers, :tiempo_espera_cardiologia, :decimal
	end
  end
end
