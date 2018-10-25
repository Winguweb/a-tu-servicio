module Reporting
  class WaitingTimeExporter < Exporter

    HEADER = ["name","days","provider"].freeze

    def initialize(user,options = {})
      @waiting_times = options[:data]
    end

    def filename
      "waiting_times_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "waiting_times"
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
      @waiting_times.each do |waiting_time|
        yield row_data(waiting_time)
      end
    end

    def row_data(waiting_time)
      [
        waiting_time.name,
        waiting_time.days,
        print_provider_name(waiting_time.provider_id),
      ]
    end

    def print_provider_name(id)
      Provider.find(id).name
    end

  end
end
