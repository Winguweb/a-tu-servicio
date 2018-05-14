class Provider < ActiveRecord::Base
  has_many :branches, dependent: :delete_all
  has_many :costs, dependent: :delete_all
  has_many :medical_assistences, dependent: :delete_all
  has_many :satisfactions, dependent: :delete_all
  has_many :specialities, dependent: :delete_all
  has_many :waiting_times, dependent: :delete_all

  def average(name)
    columns = METADATA[:precios][:averages][name][:columns]
    values = columns.map do |column|
      send(column.to_sym)
    end

    # I cannot average unless I have all the data
    valid_values = values && !values.empty? && !values.include?(nil)
    if valid_values
      (values.reduce(:+).to_f / values.size).round(2)
    else
      nil
    end
  end

  def asse?
    nombre_abreviado.include?('ASSE')
  end

  # What coverage type exists by state
  def coverage_by_state(state, type)
    sites.where(state: state, nivel: type).count
  end

  def sites_by_state(state)
    sites.where(departamento: state.proper_name).order(localidad: :asc)
  end

  def states_names
    states.uniq.map(&:name).map do |names| # Get state names
      names.split(StringConstants::SPACE).map do |n| # Separate array to capitalize
        n.capitalize
      end.join(StringConstants::SPACE) # Join two word States
    end.join(StringConstants::COMMA + StringConstants::SPACE) # Comma separate States
  end
end
