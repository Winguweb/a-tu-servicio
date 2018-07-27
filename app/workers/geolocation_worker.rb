
class GeolocationWorker
  include Sidekiq::Worker

  def perform(*args)
    branch_id = args[0]
    branch = Branch.find_by(id: branch_id)
    puts "\nAddress lookup for #{branch.name}"
    if branch.address
      location = GeocoderService.call(branch)
      puts "Resolved -> (#{location['lat']}, #{location['lng']})\n"
      sleep(5.seconds)
    else
      puts "This branch address is empty!\n"
    end
  end
end
