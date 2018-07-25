# See:
require "#{Rails.root}/lib/importer_helper"

include ImporterHelper

namespace :import do
  desc 'Import From Excel Data'
  task :all => [:environment] do
    prestadores = []
    puts 'Importing csv from Excel data'
    puts 'Truncate Provider table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Provider.table_name} RESTART IDENTITY")
    puts 'Truncate Cost table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Cost.table_name} RESTART IDENTITY")
    puts 'Truncate MedicalAssistence table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{MedicalAssistence.table_name} RESTART IDENTITY")
    puts 'Truncate Satisfaction table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Satisfaction.table_name} RESTART IDENTITY")
    puts 'Truncate WaitingTime table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{WaitingTime.table_name} RESTART IDENTITY")
    puts 'Truncate Speciality table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Speciality.table_name} RESTART IDENTITY")
    puts 'Truncate Branch table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{Branch.table_name} RESTART IDENTITY")
    puts 'Truncate State table...'
    ActiveRecord::Base.connection.execute("TRUNCATE #{State.table_name} RESTART IDENTITY")

    import_file("bogota.csv", col_sep: "\t") do |row|
      especialidad = row["especialidades"].split('-').last.titleize.strip
      lote_camas = {
        :area => row["area"],
        :cantidad => row["camas"],
      }
      sede = {
        :nombre => row["nombre_sede"].titleize.strip,
        :direccion => row["direccion_sede"],
        :localidad => row["localidad_sede"],
        :especialidades => [],
        :camas => []
      }
      prestador = {
        :nombre => row["prestador"].titleize.strip,
        :tipo => row["tipo_prestador"],
        :url_mail => row["url_mail"],
        :comunicacion => row["comunicacion"].to_s,
        :localidad => row["localidad_central"],
        :subred => row["subred"].titleize.strip,
        :direccion => row["direccion_central"],
        :satisfaccion => row["satisfaccion"],
        :tiempo_espera_cirugia_general => row["tiempo_espera_cirugia_general"],
        :tiempo_espera_ginecologia => row["tiempo_espera_ginecologia"],
        :tiempo_espera_medicina_general => row["tiempo_espera_medicina_general"],
        :tiempo_espera_medicina_interna => row["tiempo_espera_medicina_interna"],
        :tiempo_espera_obstetricia => row["tiempo_espera_obstetricia"],
        :tiempo_espera_odontologia_general => row["tiempo_espera_odontologia_general"],
        :tiempo_espera_pediatria => row["tiempo_espera_pediatria"],
        :sedes => [],
      }
      sede[:especialidades] << especialidad
      sede[:camas] << lote_camas
      prestador[:sedes] << sede
      prestador_existente = prestadores.select do |p|
        p[:nombre] == prestador[:nombre]
      end.first

      if prestador_existente.nil?
        puts "New Provider: #{prestador[:nombre].titleize.strip}"
        prestadores << prestador
      else
        sede_existente = prestador_existente[:sedes].select do |s|
          s[:nombre] == sede[:nombre]
        end.first
        if sede_existente.nil?
          sede[:especialidades] << especialidad
          prestador_existente[:sedes] << sede
          sede_existente = sede
        else
          sede_existente[:especialidades] << especialidad
        end
        cama_existente = sede_existente[:camas].select do |c|
          c[:area] == lote_camas[:area]
        end.first
        if cama_existente.nil?
          sede_existente[:camas] << lote_camas
        end
      end
    end
    puts "\n"
    total = prestadores.size
    prestadores.each_with_index do |prestador, actual|
      branches = []
      satisfactions = []
      waiting_times = []
      prestador[:sedes].each do |sede|
        specialities = []
        sede[:especialidades].each do |especialidad|
          speciality = Speciality.new(
            name: especialidad
          )
          specialities << speciality
        end
        beds = []
        sede[:camas].each do |cama|
          if cama[:area]
            bed = Bed.new(
              area: cama[:area].to_s,
              quantity: cama[:cantidad].to_i
            )
            beds << bed
          end
        end
        state = State.find_or_create_by(name: sede[:localidad])
        branch = Branch.new(
          name: sede[:nombre],
          address: sede[:direccion],
          state: state,
          specialities: specialities,
          beds: beds
        )
        branches << branch
      end
      state = State.find_or_create_by(name: prestador[:localidad])
      if prestador[:satisfaccion]
        satisfactions << Satisfaction.new(
          name: 'general',
          percentage: prestador[:satisfaccion].to_f
        )
      end
      if prestador[:tiempo_espera_cirugia_general]
        waiting_times << WaitingTime.new(
          name: "Cirugía General",
          days: prestador[:tiempo_espera_cirugia_general].to_f
        )
      end
      if prestador[:tiempo_espera_ginecologia]
        waiting_times << WaitingTime.new(
          name: "Espera Ginecología",
          days: prestador[:tiempo_espera_ginecologia].to_f
        )
      end
      if prestador[:tiempo_espera_medicina_general]
        waiting_times << WaitingTime.new(
          name: "Medicina General",
          days: prestador[:tiempo_espera_medicina_general].to_f
        )
      end
      if prestador[:tiempo_espera_medicina_interna]
        waiting_times << WaitingTime.new(
          name: "Medicina Interna",
          days: prestador[:tiempo_espera_medicina_interna].to_f
        )
      end
      if prestador[:tiempo_espera_obstetricia]
        waiting_times << WaitingTime.new(
          name: "Obstetricia",
          days: prestador[:tiempo_espera_obstetricia].to_f
        )
      end
      if prestador[:tiempo_espera_odontologia_general]
        waiting_times << WaitingTime.new(
          name: "Odontología General",
          days: prestador[:tiempo_espera_odontologia_general].to_f
        )
      end
      if prestador[:tiempo_espera_pediatria]
        waiting_times << WaitingTime.new(
          name: "Pediatría",
          days: prestador[:tiempo_espera_pediatria].to_f
        )
      end

      provider = Provider.new(
        name: prestador[:nombre],
        address: prestador[:direccion],
        website: prestador[:url_mail],
        communication_services: prestador[:comunicacion],
        is_private: prestador[:tipo].downcase().include?('privado'),
        subnet: prestador[:subred],
        branches: branches,
        state: state,
        satisfactions: satisfactions,
        waiting_times: waiting_times,
      )
      provider.save
      percentage = ((actual+1)/total.to_f * 100).round(2)
      printf("\rCompleted: %.2f%", percentage)
    end
    puts
  end
end

namespace :import do
  desc 'Import From Excel Data'
  task :resolveGeolocation => [:environment] do
    branches = Branch.all
    branches.each do |branch|
      GeolocationWorker.perform_async(branch.id)
    end
  end
end

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
