module Reporting
  class BranchExporter < Exporter
    
    HEADER = ["name", "address","georeference","town","provider_id","state_id"].freeze

    def initialize(options = {})
      @branchs = options[:data]
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
      @branchs.each do |branch|
        yield row_data(branch)
      end
    end

    def row_data(branch)
      [
        branch.name,
        branch.address,
        branch.georeference,
        branch.town,
        print_provider_name(branch.provider_id),
        branch.state_id,
      ]
    end

    def print_provider_name(id)
      Provider.find(id).name
    end
   

  end
end
