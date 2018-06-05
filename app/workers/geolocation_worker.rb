
class GeolocationWorker
  require 'net/http'
  include Sidekiq::Worker

  def perform(*args)
    url = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=#{GEOCODING_API_KEY}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    puts res.body
    branch_id = args[0]
    branch = Branch.find_by(id: branch_id)
    branch.town = 'tarea hecha'
    branch.save
    puts "HACIENDO!"
    sleep(1.second)
    puts "HECHO!"
  end
end
