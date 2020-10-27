class GeocoderService


  def self.call(branch, is_fake)
    key = GEOCODING_API_KEY
    normalized_address = normalize_address(branch.address)
    address = URI.encode("#{normalized_address}")
    puts "\nNormalized Address:\n\n--> #{normalized_address}"

    if is_fake 
      lat = rand(4.574..4.745).to_d.truncate(6).to_f
      lng = rand(-74.167..-74.021).to_d.truncate(6).to_f
      point = "POINT(#{lng} #{lat})"
      branch.georeference = point
      branch.save      
    else
      url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{key}"
  
      request = Typhoeus.get(url)
      body = JSON.parse(request.body)
  
      if body["results"].present?
        location = body["results"].first["geometry"]["location"]
        formatted_address = body["results"].first["formatted_address"]
        point = "POINT(#{location['lng']} #{location['lat']})"
        puts "\nFormatted Address:\n\n--> #{formatted_address}"
  
        branch.georeference = point
        branch.save
        location
      end
    end
  end

  def self.normalize_address(address)
    mappings = {
      '(:?^|\s)+transversal[\.]?[\s]': '\1Transversal ',
      '(:?^|\s)+diagonal[\.]?[\s]': '\1Diagonal ',
      '(:?^|\s)+carrrera[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+carrera[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+avenida[\.]?[\s]': '\1Avenida ',
      '(:?^|\s)+autopista[\.]?[\s]': '\1Autopista ',
      '(:?^|\s)+transv[\.]?[\s]': '\1Transversal ',
      '(:?^|\s)+número[\.]?[\s]': ' #',
      '(:?^|\s)+numero[\.]?[\s]': ' #',
      '(:?^|\s)+autop[\.]?[\s]': '\1Autopista ',
      '(:?^|\s)+calle[\.]?[\s]': '\1Calle ',
      '(:?^|\s)+oeste[\.]?[\s]': '\1Oeste ',
      '(:?^|\s)+norte[\.]?[\s]': '\1Norte ',
      '(:?^|\s)+auto[\.]?[\s]': '\1Autopista ',
      '(:?^|\s)+diag[\.]?[\s]': '\1Diagonal ',
      '(:?^|\s)+este[\.]?[\s]': '\1Este ',
      '(:?^|\s)+nro[\.]?[\s]': ' #',
      '(:?^|\s)+bis[\.]?[\s]': '\1Bis ',
      '(:?^|\s)+cra[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+trv[\.]?[\s]': '\1Transversal ',
      '(:?^|\s)+kra[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+sur[\.]?[\s]': '\1Sur ',
      '(:?^|\s)+cll[\.]?[\s]': '\1Calle ',
      '(:?^|\s)+cl[\.]?[\s]': '\1Calle ',
      '(:?^|\s)+aut[\.]?[\s]': '\1Autopista ',
      '(:?^|\s)+kr[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+ac[\.]?[\s]': '\1Avenida Calle  ',
      '(:?^|\s)+ak[\.]?[\s]': '\1Avenida Carrera  ',
      '(:?^|\s)+av[\.]?[\s]': '\1Avenida ',
      '(:?^|\s)+cr[\.]?[\s]': '\1Carrera ',
      '(:?^|\s)+dg[\.]?[\s]': '\1Diagonal ',
      '(:?^|\s)+tv[\.]?[\s]': '\1Transversal ',
      '(:?^|\s)+no[\.]?[\s]': ' #',
      '(:?^|\s)+nº[\.]?[\s]?': ' #',
      '(:?^|\s)+n°[\.]?[\s]?': ' #',
      '(:?^|\s)+#[\.]?[\s]?': ' #',
      '(:?^|\s)+c\.[\s]': '\1Calle ',
      '(:?^|\s)+k\.[\s]': '\1Carrera ',
      '(:?^|\s)+a\.[\s]': '\1Avenida ',
      '(:?^|\s)+d\.[\s]': '\1Diagonal ',
      '(:?^|\s)+n\.[\s]?\d+': '#\1 ',
      '(:?^|\s)+n\.[\s]': '\1Norte ',
      '(:?^|\s)+s\.[\s]': '\1Sur ',
      '(:?^|\s)+e\.[\s]': '\1Este ',
      '(:?^|\s)+o\.[\s]': '\1Oeste ',
      '(:?^|\s)+-[\s]*': '-',
    }
    normalized_address = address.strip.mb_chars.downcase
    mappings.each do |(from, to)|
      normalized_address = normalized_address.gsub(/#{from}/, to)
      normalized_address = normalized_address.gsub(/(:?\d+[a-zA-Z]?)[\s-]/, &:upcase)
      normalized_address = normalized_address.gsub(/(:?\d+)\s*(:?[a-zA-Z]?\s)/, '\1\2 '.strip)
      normalized_address = normalized_address.gsub(/(:?\d+)\s+(:?\d+)/, '\1-\2 '.strip)
    end
    separator = /-\d*/.match(normalized_address).to_a.first
    normalized_address = "#{normalized_address.split(separator).first}#{separator}" unless separator.nil?
    normalized_address = "#{normalized_address}, Bogotá, Colombia"
    return normalized_address
  end
end
