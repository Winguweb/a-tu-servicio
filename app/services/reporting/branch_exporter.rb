module Reporting
  class BranchExporter < Exporter

    HEADER = %w[name address georeference provider].freeze

    def initialize(user, options = {})
      @branchs = options[:model_klass].includes(:provider).all
    end

    def filename
      "branchs_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "branchs"
    end

    def csv_stream
      Enumerator.new do |result|
        result << csv_header

        yielder do |row|
          result << csv_row(row)
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
      @branchs.each do |branch|
        yield row_data(branch)
      end
    end

    def row_data(branch)
      [
        branch.name,
        branch.address,
        branch.georeference,
        branch.provider.name,
      ]
    end

  end
end
