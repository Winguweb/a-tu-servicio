module Reporting
  class SpecialityExporter < Exporter

    HEADER = ["provider","specialities"].freeze

    def initialize(user,options = {})
      @specialities = options[:data]
    end

    def filename
      "specialities_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "specialities"
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
      @specialities.pluck(:branch_id).uniq.each do |branch_id|
       yield row_data(Branch.find(branch_id).name,  Speciality.where(branch: Branch.find(branch_id)).pluck(:name))
      end
      # @specialities.each do |speciality|
      #   yield row_data(speciality)
      # end
    end


    def row_data(provider , specialities)
      [
        provider,
        specialities
      ]
    end

    def print_branch_name(id)
      Branch.find(id).name
    end

  end
end
