module Reporting
  class SpecialityExporter < Exporter

    HEADER = %w[speciality provider branch].freeze

    def initialize(user, options = {})
      @specialities = options[:model_klass].includes(branch: :provider)
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
      @specialities.group_by(&:branch).each do |branch, branch_specialities|
        branch_specialities.each do |speciality|
          yield row_data(branch, speciality)
        end
      end
    end


    def row_data(branch, speciality)
      [
        speciality.name,
        branch.provider.name,
        branch.name
      ]
    end
  end
end
