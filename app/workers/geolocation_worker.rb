
class GeolocationWorker
  include Sidekiq::Worker

  def perform(*args)
    branch_id = args[0]
    branch = Branch.find_by(id: branch_id)
    puts "\nAddress lookup for #{branch.name}"
    if branch.georeference
      puts "\nGeoreference for #{branch.name} exists"
      return
    end
    if branch.address.nil?
      puts "This branch address is empty!\n"
      return
    end
    if branch.address
      location = GeocoderService.call(branch)
      puts "Resolved -> (#{location['lat']}, #{location['lng']})\n"
      sleep(5.seconds)
    end
  end
end
