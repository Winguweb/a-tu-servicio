
class GeolocationWorker
  include Sidekiq::Worker

  def perform(*args)
    branch_id = args[0]
    branch = Branch.find_by(id: branch_id)
    puts "\n=================================================================="
    puts "\nAddress lookup for #{branch.name}"
    puts "\n------------------------------------------------------------------"
    puts "\nOriginal Address:\n\n--> #{branch.address}\n"
    if branch.georeference
      puts "\nGeoreference for #{branch.name} exists\n\n"
      puts "\n=================================================================="
      return
    end
    if branch.address.nil?
      puts "\nThis branch address is empty!\n\n"
      puts "\n=================================================================="
      return
    end
    if branch.address
      location = GeocoderService.call(branch)
      puts "\nResolved:\n(#{location['lat']}, #{location['lng']})\n\n"
      puts "\n=================================================================="
      sleep(5.seconds)
    end
  end


end
