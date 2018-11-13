class DetailsWaitingTimesResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml"))
    @branch = branch
    @surveys_source_waiting_times = _get_survey_source_waiting_times
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _get_survey_source_waiting_times
    surveys = _select_survey_attributes
    surveys = _from_this_branch_and_step(surveys)
    surveys = _grouped_by_client(surveys)
    surveys = _return_answer_value(surveys)
  end

  def _select_survey_attributes
    Survey.select('client_id, answer_id, answer_data, question_value, step_id')
  end

  def _from_this_branch_and_step(surveys)
    surveys.where(branch_id: @branch.id).where(step_id: @surveys_structure['structure']['speciality_waiting_times'])
  end

  def _grouped_by_client(surveys)
    surveys.group_by{ | survey | survey.client_id }
  end

  def _return_answer_value(surveys)
    surveys.values.map do | answer |
      answer.pluck(:answer_data).map do | answer_data |
        answer_data['value']
      end
    end
  end

  def _get_waiting_times_count_by_speciality
    rating_map = [:bad, :acceptable, :good]
    @surveys_source_waiting_times.each_with_object(Hash.new({})) do | word, counts |
      rating = rating_map[word.second - 1]
      counts[word.first] = {} unless counts[word.first].present?
      counts[word.first] = {:bad => 0, :acceptable => 0, :good => 0} if counts[word.first].blank?
      counts[word.first][rating] += 1
    end
  end

  def _get_total_waiting_times(speciality)
     _get_waiting_times_count_by_speciality[speciality].values.sum
  end

  def _get_waiting_times_count_over_total

    _get_waiting_times_count_by_speciality.map do | waiting_times |
      speciality = waiting_times.first
      return {
        name: speciality,
        percentage: 0
      } if _get_total_waiting_times(speciality) == 0
      {
        name: speciality,
        percentage: {
          bad: (waiting_times.second[:bad].to_f / _get_total_waiting_times(speciality) * 100).round(2),
          acceptable: (waiting_times.second[:acceptable].to_f / _get_total_waiting_times(speciality) * 100).round(2),
          good: (waiting_times.second[:good].to_f / _get_total_waiting_times(speciality) * 100).round(2),
        }
      }
    end
  end

  def _response
    {
      details: {
        waiting_times: _get_waiting_times_count_over_total
      }
    }
  end
end
