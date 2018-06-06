
class GeocoderService

  def self.call(branch)
    key = GEOCODING_API_KEY
    address = URI.encode("#{branch.address}, Bogotá, Colombia")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{key}"

    request = Typhoeus.get(url)
    body = JSON.parse(request.body)

    location = body["results"].first["geometry"]["location"]
    point = "POINT(#{location['lng']} #{location['lat']})"

    branch.georeference = point
    branch.save
    location
  end

end
