module Reporting
  class SurveyExporter < Exporter

    SURVEY_COLUMNS = [
      { id: 1 },
      { id: 2 },
      {
        id: 5,
        custom_label: 'Tiempo de espera del servicio'
      },
      { id: 7 },
      {
        id: [9, 10],
        custom_label: 'Detalle calificación servicio'
      },
      { id: 11 },
      { id: 12 },
      {
        id: [13, 14],
        custom_label: 'Detalle calificación personal'
      },
      { id: 15 },
      {
        id: [16, 17],
        custom_label: 'Detalle calificación satisfaccion'
      }
    ].freeze
    private_constant :SURVEY_COLUMNS

    def initialize(user, options = {})
      @user = user
      @surveys = options[:model_klass].includes(branch: :provider)
    end

    def filename
      "surveys_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "surveys"
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

    def user_logged_in?
      !!@user
    end

    def header
      return @header if defined?(@header)

      @header = %w[provider_name branch_name]

      SURVEY_COLUMNS.each do |column|
        label = if column.key?(:custom_label)
          column[:custom_label]
        else
          $survey_data.steps_labels[column[:id]]
        end
        @header << label
      end

      @header
    end

    def csv_header
      CSV::Row.new(header, header, true).to_s
    end

    def csv_row(values)
      CSV::Row.new(header, values).to_s
    end

    def yielder
      @surveys.group_by{|s| [s.client_id, s.branch]}.each do |(_, branch), survey_responses|
        process_survey_responses(survey_responses).each do |row_responses|
          yield row_data(branch, row_responses)
        end
      end
    end

    def process_survey_responses(survey_responses)
      # TO-DO: I harcoded this in here because is the only step that has this situation
      multiple_responses_entry_step_id = 11
      multiple_responses_group = [ 11, 12, 13, 14 ]

      multiple_responses_columns = survey_responses.select do |response|
        multiple_responses_group.include?(response.step_id)
      end

      common_colums_data = survey_responses.select do |response|
        not multiple_responses_group.include?(response.step_id)
      end.each_with_object({}) do |response, _hash|
        _hash[response.step_id] = response.answer_data['label']
      end

      # TO-DO: All this logic below is very order sensitive of the records
      # the assumptions is that the grouped records are next to each other
      response_group = {}
      within_group = false
      multiple_columns_groups = multiple_responses_columns.each_with_object([]) do |response, _array|
        if response.step_id == multiple_responses_entry_step_id
          if within_group
            _array.push(response_group)
            within_group = false
          end
          response_group = {}
          within_group = true
        end
        response_group[response.step_id] = response.answer_data['label']
      end
      multiple_columns_groups.push(response_group) if within_group
      # END | TO-DO

      multiple_columns_groups.map do |group|
        common_colums_data.merge(group)
      end
    end

    def row_data(branch, row_responses)
      responses_columns = SURVEY_COLUMNS.map do |column|
        id = if column[:id].is_a?(Array)
          column[:id].detect{ |id| row_responses[id] }
        else
          column[:id]
        end

        row_responses[id]
      end

      [
        branch.provider.name,
        branch.name
      ].push(*responses_columns)
    end
  end
end
