module Reporting
  class WaitingTimeExporter < Exporter

    HEADER = %w[name days provider].freeze

    def initialize(user, options = {})
      @waiting_times = options[:model_klass].includes(:provider).all
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
      @waiting_times.group_by(&:provider).each do |provider, provider_waiting_times|
        provider_waiting_times.each do |waiting_time|
          yield row_data(provider, waiting_time)
        end
      end
    end

    def row_data(provider, waiting_time)
      [
        waiting_time.name,
        waiting_time.days,
        provider.name,
      ]
    end

  end
end
