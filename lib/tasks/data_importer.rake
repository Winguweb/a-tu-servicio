# See:
require "#{Rails.root}/lib/importer_helper"
require 'sidekiq/api'

include ImporterHelper

namespace :update do
  desc 'Update providers and branches'

  task :all => [:environment] do
    base_csv = File.read('./db/data/bogota.tsv')
    new_data_csv = File.read('./db/data/data_update.csv')
    save_branches = []
    rows = []

    updated = 0
    created = 0
    puts 'Starting process...'

    CSV.parse(new_data_csv, headers: true, header_converters: :symbol, col_sep: ",", row_sep: :auto) do |row|
      past_name = row[:sede_nombre_anterior].strip.downcase
      
      @branch = Branch.where('lower(name) = ?', past_name).first
      if !@branch.present?
        @branch = Branch.where('lower(name) = ?', row[:sede_nombre_actual].strip.downcase).first
      end
      especialidad = row[:especialidades].split('-').drop(1).map(&:strip).join(' - ')

      data = {
        :nombre_sede => row[:sede_nombre_actual].strip,
        :direccion => row[:direccion],
        :nombre_prestador => row[:prestador].strip,
        :tipo_prestador => row[:naju_nombre],
        :mostrar => true,
        :email => row[:email],
        :comunicacion => row[:telefono].to_s,
        :subred => 'No aplica',
        :especialidades => [],
        :camas => [],        
        :update => @branch.present? && @branch.id
      }

      if @branch.present?
        save_branches << @branch.id
        File.write('./db/data/to_save.txt', "save #{@branch.id}\n", mode: 'a')      
      end


      data_exists = rows.detect do |p|
        p[:nombre_sede].downcase == data[:nombre_sede].downcase
      end

      if data_exists.nil?
        data[:especialidades] << especialidad
        rows << data
      else
        data_exists[:especialidades] << especialidad
      end
    end
    
    delete_branches = Branch.where.not(id: save_branches)
    delete_providers = Provider.where(id: delete_branches.pluck('provider_id'))
    delete_branches.each do |delete_branch|
      File.write('./db/data/to_delete.txt', "delete #{delete_branch.id}\n", mode: 'a')      
    end    

    puts 'Creating...'

    total = rows.size
    rows.each_with_index do |data_row, actual|

      if data_row[:update]
        branch = Branch.find(data_row[:update])
        Speciality.where(branch_id: branch.id).destroy_all

        specialities = []
        data_row[:especialidades].each do |especialidad|
          speciality = Speciality.new(
            name: especialidad
          )
          specialities << speciality
        end

        branch.update(
          name: data_row[:nombre_sede],
          slug: data_row[:nombre_sede].parameterize,
          address: data_row[:direccion],
          specialities: specialities
        )        
        branch.save
        # File.write('./db/data/updated.txt', "#{branch.id} #{branch.name} \n", mode: 'a')      
        updated = updated + 1
      else
        specialities = []
        data_row[:especialidades].each do |especialidad|
          speciality = Speciality.new(
            name: especialidad
          )
          specialities << speciality
        end

        branch = Branch.new(
          name: data_row[:nombre_sede],
          slug: data_row[:nombre_sede].parameterize,
          address: data_row[:direccion],
          specialities: specialities,
        )
        
        provider = Provider.new(
          name: data_row[:nombre_prestador],
          address: data_row[:direccion],
          email: data_row[:email],
          show: data_row[:mostrar],
          communication_services: data_row[:comunicacion],
          is_private: data_row[:tipo_prestador].downcase().include?('privada'),
          subnet: data_row[:subred],
          branches: [branch],
        )

        # File.write('./db/data/created.txt', "#{branch.id} #{branch.name} \n", mode: 'a')      
        created = created + 1

        Branch.without_auto_index do
          provider.save
        end
      end
          
    end
    
    puts 'Deleting obsolete branches and providers...'
    delete_providers.destroy_all
    delete_branches.destroy_all

    puts 'Results:'
    puts 'update:' + updated.to_s
    puts 'create:' + created.to_s
  end
end

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

    imported_csv = File.read('./db/data/bogota.tsv')
    mostrar = 0
    destacar = 0
    totales = 0
    CSV.parse(imported_csv, headers: true, header_converters: :symbol, col_sep: "\t", :quote_char => "`") do |row|
      especialidad = row[:especialidades].split('-').drop(1).map(&:strip).join(' - ')
      lote_camas = {
        :area => row[:area],
        :cantidad => row[:camas],
      }
      sede = {
        :nombre => row[:nombre_sede].strip,
        :direccion => row[:direccion_sede],
        :localidad => row[:localidad_sede],
        :especialidades => [],
        :camas => []
      }
      prestador = {
        :nombre => row[:prestador].strip,
        :tipo => row[:tipo_prestador],
        :website => row[:website],
        :destacado => row[:destacado].present? && (row[:destacado] == 'x' || row[:destacado] == 'X'),
        :mostrar => row[:mostrar].present? && (row[:mostrar] == 'x' || row[:mostrar] == 'X'),
        :email => row[:email],
        :comunicacion => row[:comunicacion].to_s,
        :localidad => row[:localidad_central],
        :subred => row[:subred].strip,
        :direccion => row[:direccion_central],
        :satisfaccion => row[:satisfaccion],
        :tiempo_espera_cirugia_general => row[:tiempo_espera_cirugia_general],
        :tiempo_espera_ginecologia => row[:tiempo_espera_ginecologia],
        :tiempo_espera_medicina_general => row[:tiempo_espera_medicina_general],
        :tiempo_espera_medicina_interna => row[:tiempo_espera_medicina_interna],
        :tiempo_espera_obstetricia => row[:tiempo_espera_obstetricia],
        :tiempo_espera_odontologia_general => row[:tiempo_espera_odontologia_general],
        :tiempo_espera_pediatria => row[:tiempo_espera_pediatria],
        :sedes => [],
      }
      sede[:especialidades] << especialidad
      sede[:camas] << lote_camas
      prestador[:sedes] << sede

      prestador_existente = prestadores.detect do |p|
        p[:nombre].downcase == prestador[:nombre].downcase
      end

      if prestador_existente.nil?
        # puts "New Provider: #{prestador[:nombre].strip}"
        printf "."
        prestadores << prestador
      else
        sede_existente = prestador_existente[:sedes].detect do |s|
          s[:nombre].downcase == sede[:nombre].downcase
        end

        if sede_existente.nil?
          prestador_existente[:sedes] << sede
          sede_existente = sede
        else
          unless sede_existente[:especialidades].map(&:downcase).include?(especialidad.downcase)
            sede_existente[:especialidades] << especialidad
          end
        end

        cama_existente = sede_existente[:camas].detect do |c|
          c[:area].try(:downcase) == lote_camas[:area].try(:downcase)
        end
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
          slug: sede[:nombre].parameterize,
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
        website: prestador[:website],
        email: prestador[:email],
        show: prestador[:mostrar],
        featured: prestador[:destacado],
        communication_services: prestador[:comunicacion],
        is_private: prestador[:tipo].downcase().include?('privado'),
        subnet: prestador[:subred],
        branches: branches,
        state: state,
        satisfactions: satisfactions,
        waiting_times: waiting_times,
      )
      mostrar = mostrar + 1 if prestador[:mostrar]
      destacar = destacar + 1 if prestador[:destacado]
      totales = totales + 1
      Branch.without_auto_index do
        provider.save
      end
      percentage = ((actual+1)/total.to_f * 100).round(2)
      printf("\rCompleted: %.2f%", percentage)
      printf(", Total: %d", totales)
      printf(", Mostrar: %d", mostrar)
      printf(", Destacar: %d", destacar)
    end
    puts "\n"
    puts 'Providers uploaded'
    puts "\n"
    puts 'Indexing branches'
    puts "\n"
    Branch.reindex!
    puts 'Indexing completed!'
    puts
    Rake::Task["import:resolveGeolocation"].execute
  end

  desc 'Resolve geolocation from addresses'
  task :resolveGeolocation => [:environment] do
    puts 'Generating tasks: resolve geolocation from address'
    puts "\n"

    # clear all queues
    Sidekiq::Queue.all.each &:clear
    # 1. Clear retry set
    Sidekiq::RetrySet.new.clear
    # 2. Clear scheduled jobs
    Sidekiq::ScheduledSet.new.clear
    # 3. Clear 'Processed' and 'Failed' jobs
    Sidekiq::Stats.new.reset
    # 3. Clear 'Dead' jobs statistics
    Sidekiq::DeadSet.new.clear

    branches = Branch.joins(:provider).where(providers: { show: true })
    branches.each do |branch|
      GeolocationWorker.perform_async(branch.id, true)
    end
    puts 'Tasks generated'
    puts
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
    # specialities_data
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
