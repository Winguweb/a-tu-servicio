module Reporting
  class ProviderExporter < Exporter
    
  
    HEADER = ["name","address","subnet","abbreviation","website","email", "affiliations", "financed_affiliations", "communication_services", "logo_url", "is_private", "show", "featured", "state_id"].freeze

    def initialize(options = {})
      @providers = options[:data]
    end

    def filename
      "providers_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "providers"
    end

    def csv_stream
      Enumerator.new do |result|
        result << csv_header

        yielder do |row|
          result << csv_row(row)
        end
      end
    end

    def data_stream
      Enumerator.new do |result|
        result << header

        yielder do |row|
          result << row
        end
      end
    end

 
    private

    def header
      @header ||= HEADER
    end


    def csv_header
      CSV::Row.new(header, header, true).to_s
    end

    def csv_row(values)
      CSV::Row.new(header, values).to_s
    end

    def yielder
      @providers.each do |provider|
        yield row_data(provider)
      end
    end

    def row_data(provider)
      [
        provider.name,
        provider.address,
        provider.subnet,
        provider.abbreviation,
        provider.website,
        provider.email,
        provider.affiliations,
        provider.financed_affiliations,
        provider.communication_services,
        provider.logo_url,
        provider.is_private,
        provider.show,
        provider.featured,
        provider.state_id
      ]
    end
  end
end
