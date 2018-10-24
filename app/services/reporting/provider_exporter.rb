module Reporting
  class ProviderExporter < Exporter
    
  
    HEADER = ["name","address","subnet","website","email","communication_services", "is_private", "state_id"].freeze

    def initialize(user,options = {})
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
        provider.website,
        provider.email,
        provider.communication_services,
        provider.is_private,
        provider.state_id
      ]
    end
  end
end
