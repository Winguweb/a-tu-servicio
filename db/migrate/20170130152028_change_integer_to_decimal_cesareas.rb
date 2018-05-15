class ChangeIntegerToDecimalCesareas < ActiveRecord::Migration[5.2]
  def change
    change_column :providers, :indice_cesareas, :decimal
  end
end
