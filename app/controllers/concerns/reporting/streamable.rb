# Internal: In order to be able to return data as CSV as a Stream
module Reporting
  module Streamable
    include ActiveSupport::Concern

    def stream_csv(exporter, user, *args)
      raise MistypeError.new(self, Exporter, __method__) unless exporter.ancestors.include? Exporter

      exporter = exporter.new(user, *args)

      set_csv_file_headers(exporter.filename)
      set_streaming_headers

      response.status = 200

      self.response_body = exporter.csv_stream
    end

    def stream_xlsx(exporter, user, *args)
      raise MistypeError.new(self, Exporter, __method__) unless exporter.ancestors.include? Exporter

      exporter = exporter.new(user, *args)

      buffer = StringIO.new

      xlsx = Xlsxtream::Workbook.new(buffer)

      xlsx.write_worksheet(exporter.sheetname) do |sheet|
        exporter.data_stream.each do |row|
          sheet << row
        end
      end
      xlsx.close

      buffer.rewind

      set_xlsx_file_headers(exporter.filename)
      set_streaming_headers

      # send_data buffer.read, filename: "#{exporter.filename}.xlsx", type: "application/vnd.ms-excel"
      self.response_body = buffer.read
    end

    private

    def set_csv_file_headers(filename)
      file_name = "#{filename}.csv"
      headers['Content-Type'] = 'text/csv; charset=utf-8; header=present'
      headers['Content-Disposition'] = "attachment; filename=\"#{file_name}\""
      headers["X-Accel-Buffering"] = "no"
    end

    def set_xlsx_file_headers(filename)
      file_name = "#{filename}.xlsx"
      headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8; header=present'
      headers['Content-Disposition'] = "attachment; filename=\"#{file_name}\""
    end

    def set_streaming_headers
      headers['Cache-Control'] = 'no-cache'
      headers['X-Accel-Buffering'] = 'no'
      headers.delete('Content-Length')
    end
  end

  class MistypeError < StandardError
    attr_reader :object

    def initialize(object, expected_class, method_name)
      @object = object
      super("The Method ##{method_name} called in #{object.class.name} was expecting an exporter kind of: #{expected_class.to_s} Class.")
    end
  end
end
