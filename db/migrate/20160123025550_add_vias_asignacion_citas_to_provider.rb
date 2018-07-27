class AddViasAsignacionCitasToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :vias_asignacion_citas, :string
  end
end
