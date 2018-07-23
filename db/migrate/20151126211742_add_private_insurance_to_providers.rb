class AddPrivateInsuranceToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :private_insurance, :boolean, default: false
    Provider.find_each do |p|
      if p.nombre_abreviado.include?('Seguro Privado')
        p.private_insurance = true
        p.save!
      end
    end
  end
end
