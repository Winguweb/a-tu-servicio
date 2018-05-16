# See:
require "#{Rails.root}/lib/importer_helper"

include ImporterHelper

namespace :importer do
  @year = '2016'

  desc 'Importing everything'
  task :all, [:year] => [:environment] do |t, args|
    puts 'Import all data'
    @year = args[:year] || @year

    Rake::Task['importer:all'].enhance do
      Rake::Task['importer:states'].invoke
    end

    providers
    specialities_data
    costs_data
    medical_assistences_data
    satisfactions_data
    waiting_times_data
    branches_data

    # provider_data
    # calculate_maximums
    # assign_search_name
    # structure
  end

  #
  # Los departamentos se importan de config/states.yml
  #
  desc 'Import States'
  task states: [:environment] do
    puts 'Import states'
    states = YAML.load_file('config/states.yml')
    states.each do |state|
      State.find_or_create_by(
        name: state
      )
    end
  end

  #
  # Create providers
  #
  def providers
    puts 'Delete providers'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Provider.table_name} RESTART IDENTITY")

    puts 'Creating providers'

    import_file(@year + "/estructura.csv", col_sep: ';') do |row|
      provider = Provider.new(
        id: row[0],
        abbreviation: row[1],
        name: row[2],
        website: row[3],
        financed_affiliations: row[4],
        affiliations: row[6],
        communication_services: row[7],
        is_private: row[1].include?('Seguro Privado')
      )
      # Set private insurances
      provider.save
    end
  end

  #
  # Import provider data
  #

  def costs_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{Cost.table_name} RESTART IDENTITY")
    puts "Importing Costs data..."
    import_file(@year + "/precios.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('precios')
      values = row.fields[1..-1]
      data = descriptions.zip(values)
      data.each do |cost|
        provider.costs << Cost.new(
          name: cost[0],
          amount: cost[1].to_i
        )
      end
      provider.save
    end
  end

  def medical_assistences_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{MedicalAssistence.table_name} RESTART IDENTITY")
    puts "Importing Medical Assistences data..."
    import_file(@year + "/metas.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('metas')
      values = row.fields[1..-1]
      data = descriptions.zip(values)
      data.each do |medical_assistence|
        provider.medical_assistences << MedicalAssistence.new(
          name: medical_assistence[0],
          percentage: medical_assistence[1].to_f/100.0
        )
      end
      provider.save
    end
  end

  def satisfactions_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{Satisfaction.table_name} RESTART IDENTITY")
    puts "Importing Satisfaction data..."
    import_file(@year + "/satisfaccion_derechos.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('satisfaccion_derechos')
      values = row.fields[1..-1]
      data = descriptions.zip(values)
      data.each do |satisfaction|
        provider.satisfactions << Satisfaction.new(
          name: satisfaction[0],
          percentage: satisfaction[1].to_f/100.0
        )
      end
      provider.save
    end
  end

  def waiting_times_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{WaitingTime.table_name} RESTART IDENTITY")
    puts "Importing Waiting Times data..."
    import_file(@year + "/tiempos_espera.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('tiempos_espera')
      values = row.fields[1..-1]
      data = descriptions.zip(values)
      data.each do |waiting_time|
        provider.waiting_times << WaitingTime.new(
          name: waiting_time[0],
          days: waiting_time[1].to_f
        )
      end
      provider.save
    end
  end

  def specialities_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{Speciality.table_name} RESTART IDENTITY")
    puts "Importing Specialities data..."
    import_file(@year + "/rrhh.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('rrhh')
      values = row.fields[1..-1]
      data = descriptions.zip(values)
      data.each do |speciality|
        provider.specialities << Speciality.new(
          name: speciality[0],
          professionals_count: speciality[1].to_f
        )
      end
      provider.save
    end
  end

  def branches_data
    ActiveRecord::Base.connection.execute("TRUNCATE #{Branch.table_name} RESTART IDENTITY")
    puts "Importing Branches data..."
    import_file(@year + "/sedes.csv", col_sep: ';') do |row|
      provider = Provider.find_by(id: row[0].to_i)
      descriptions = get_description('rrhh')[5..-1]
      values = row.fields[5..-1]
      data = descriptions.zip(values)
      branch = Branch.new(
        address: row[1],
        town: row[3],
      )
      branch.level_list << row[4]
      branch.state = State.find_or_create_by(name: row[2])
      provider.branches << branch
      data.each do |category|
        if category[1]
          branch.category_list << category[0]
        end
      end
      branch.save
      provider.save
    end
  end

  def provider_data
    [:precios, :metas, :satisfaccion_derechos, :tiempos_espera].each do |importable|
      puts "Importing #{importable}"
      importing(importable, @year)
    end

    [:rrhh, :solicitud_consultas].each do |importable|
      puts "Importing #{importable}"
      importing(importable, @year)
    end

    puts 'Importing sites'
    importing('sedes', @year) do |provider, parameters|
      state = State.find_by_name(parameters['departamento'].strip.mb_chars.downcase.to_s)
      unless state.nil?
        parameters['state_id'] = state.id
        provider.sites.create(parameters)
      end
    end
  end

  #
  # Get structure
  #
  def structure
    Provider.all.each do |provider|
      provider_structure(provider)
    end
  end

  #
  # Assign search name
  #
  def assign_search_name
    Provider.all.each do |provider|
      search_name = "#{provider.nombre_abreviado} - #{provider.nombre_completo}"
      provider.update_attributes(search_name: search_name)
    end
  end

  #
  # Calculate Maximums
  #
  def calculate_maximums
    maximums = ProviderMaximum.first || ProviderMaximum.new
    # Waiting times
    puts 'Calculating Waiting times'
    value = 0
    Provider.all.each do |provider|
      ['medicina_general', 'pediatria', 'cirugia_general',
       'ginecotocologia', 'cardiologia'].map do |field|
        the_thing = provider.send("tiempo_espera_#{field}".to_sym)
        if  the_thing && the_thing > value
          value = provider.send("tiempo_espera_#{field}".to_sym)
        end
      end
    end

    maximums.waiting_time = value

    # Affiliates
    puts 'Calculating Affiliates'
    maximums.affiliates = Provider.all.map(&:afiliados).compact.reduce(:+)

    # Tickets
    puts 'Calculating Tickets'
    Provider.all.map do |provider|
      [:medicamentos, :tickets, :tickets_urgentes, :estudios].map do |ticket|
        average = provider.average(ticket)
        if average && average > value
          value = average
        end
      end
    end
    maximums.tickets = value

    # Personnel
    puts 'Calculating personnel'
    value = 0
    Provider.all.map do |provider|
      [:medicos_generales_policlinica,
       :medicos_de_familia_policlinica,
       :medicos_pediatras_policlinica,
       :medicos_ginecologos_policlinica,
       :auxiliares_enfermeria_policlinica,
       :licenciadas_enfermeria_policlinica].map do |position|
        quantity = provider.send(position).to_f
        if quantity > value
          value = quantity
        end
      end
    end
    maximums.personnel = value
    maximums.save
  end

end
