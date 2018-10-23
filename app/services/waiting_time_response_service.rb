class WaitingTimeResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml"))
    @surveys_representation = @surveys_structure['representation']['waiting_times']
    @branch = branch
    @initial_source_waiting_times = @branch.provider.waiting_times
    @surveys_source_waiting_times = _get_survey_source_waiting_times
    @common_info = CommonInfoService.call
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _get_survey_source_waiting_times
    surveys = _select_waiting_times_attributes
    surveys = _from_this_branch_and_step(surveys)
    surveys = _grouped_by_client(surveys)
    surveys = _return_answer_value(surveys)
    surveys = _where_not_empty(surveys)
  end

  def _select_waiting_times_attributes
    Survey.select('client_id, answer_id, answer_data, question_value, step_id')
  end

  def _from_this_branch_and_step(surveys)
    surveys.where(branch_id: @branch.id)
    .where(step_id: @surveys_structure['structure']['speciality_waiting_times'])
  end

  def _grouped_by_client(surveys)
    surveys.group_by{ | survey | survey.client_id }
  end

  def _return_answer_value(surveys)
    surveys.values.map do | speciality_waiting_times |
      speciality_waiting_times.pluck(:answer_data).map do | answer_data |
        answer_data['value']
      end
    end
  end

  def _where_not_empty(surveys)
    surveys.select do | speciality_waiting_times |
      speciality_waiting_times.second.present?
    end
  end

  def _initial_source_waiting_times_total
    @initial_source_waiting_times.reduce(0){ |last, w| last + w.days }
  end

  # Used for percentage/volume bar number
  def _initial_source_waiting_times
    (_initial_source_waiting_times_total.to_f / @initial_source_waiting_times.count.to_f).round(1)
  end

  # Used for percentage/volume bar width
  def _initial_source_waiting_times_percentage_from_worst
    (_initial_source_waiting_times_total.to_f / @common_info.worst_total_waiting_times.to_f).round(2)
  end

  def _initial_source_waiting_time_name(waiting_time)
    waiting_time.name
  end

  def _initial_source_waiting_time_score(waiting_time)
    waiting_time_representation = @surveys_representation.detect do | representation |
      representation["speciality"] == waiting_time[:name]
    end

    return unless waiting_time_representation.present?

    waiting_time_mappings = waiting_time_representation["mappings"].pluck("value", "range")
    range = waiting_time_mappings.detect do | mapping |
      days = BigDecimal(waiting_time[:days])
      min_days = BigDecimal(mapping.second["min"])
      max_days = BigDecimal(mapping.second["max"])
      days >= min_days && days <= max_days
    end
    return range.first if range.present?
  end

  def _initial_source_waiting_times_by_speciality
    @initial_source_waiting_times.order(name: :asc).map do | waiting_time |
      # Percentage relation between actual branch provider's waiting times and worst provider's waiting times
      {
        name: _initial_source_waiting_time_name(waiting_time),
        score: _initial_source_waiting_time_score(waiting_time),
      }
    end
  end

  def _surveys_source_waiting_times
    count = @surveys_source_waiting_times.size
    total = @surveys_source_waiting_times.reduce(0) do | sum, waiting_time |
      sum + waiting_time.second
    end
    average = total.to_f / count.to_f
    (average / 3).round(2)
  end

  def _surveys_source_waiting_times_by_speciality
    waiting_times_by_speciality = {}
    @surveys_source_waiting_times.each do | speciality, score |
      waiting_times_by_speciality[speciality] = [] if waiting_times_by_speciality[speciality].nil?
      waiting_times_by_speciality[speciality] << score
    end

    waiting_times_by_speciality = waiting_times_by_speciality.map do | speciality, waiting_times |
      {name: speciality, score: waiting_times.sum / waiting_times.size}
    end
  end

  def _has_initial_source_waiting_times_information
    @branch.provider.waiting_times.present?
  end



  def _has_surveys_source_waiting_times_information
    @surveys_source_waiting_times.present?
  end

  def _response
    {
      initial_source: {
        waiting_times: _initial_source_waiting_times,
        waiting_times_by_speciality: _initial_source_waiting_times_by_speciality,
        waiting_times_percentage_from_worst: _initial_source_waiting_times_percentage_from_worst,
        has_waiting_times_information: _has_initial_source_waiting_times_information
      },
      surveys_source: {
        waiting_times: _surveys_source_waiting_times,
        waiting_times_by_speciality: _surveys_source_waiting_times_by_speciality,
        has_waiting_times_information: _has_surveys_source_waiting_times_information,
      }
    }
  end
end
