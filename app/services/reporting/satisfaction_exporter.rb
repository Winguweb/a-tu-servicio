module Reporting
  class SatisfactionExporter < Exporter

    HEADER = ["name","percentage","satisfaction"].freeze

    def initialize(options = {})
      @satisfactions = options[:data]
    end

    def filename
      "satisfactions_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "satisfactions"
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
      @satisfactions.each do |satisfaction|
        yield row_data(satisfaction)
      end
    end

    def row_data(satisfaction)
      [
        satisfaction.name,
        satisfaction.percentage,
        print_provider_name(satisfaction.provider_id),
      ]
    end

    def print_provider_name(id)
      Provider.find(id).name
    end

  end
end
