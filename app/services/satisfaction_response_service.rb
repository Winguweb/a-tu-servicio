class SatisfactionResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml"))
    @branch = branch
    @initial_source_satisfactions = @branch.provider.satisfactions
    @surveys_source_satisfactions = _get_survey_source_satisfactions

    @common_info = CommonInfoService.call
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _get_survey_source_satisfactions
    surveys = _select_satisfactions_attributes
    surveys = _from_this_branch_and_step(surveys)
    surveys = _grouped_by_client(surveys)
    surveys = _return_answer_value(surveys)
    surveys = _where_not_empty(surveys)
  end

  def _select_satisfactions_attributes
    Survey.select('client_id, answer_id, answer_data, question_value, step_id')
  end

  def _from_this_branch_and_step(surveys)
    surveys.where(branch_id: @branch.id)
    .where(step_id: @surveys_structure['structure']['speciality_satisfaction'])
  end

  def _grouped_by_client(surveys)
    surveys.group_by{ | survey | survey.client_id }
  end

  def _return_answer_value(surveys)
    surveys.values.map do | speciality_satisfaction |
      speciality_satisfaction.pluck(:answer_data).map do | answer_data |
        answer_data['value']
      end
    end
  end

  def _where_not_empty(surveys)
    surveys.select do | speciality_satisfaction |
      speciality_satisfaction.second.present?
    end
  end

  def _initial_source_satisfaction
    (@initial_source_satisfactions.present? ? @initial_source_satisfactions.first.percentage.to_f : 0.0).round(2)
  end

  def _initial_source_satisfaction_from_best
    (_initial_source_satisfaction / @common_info.best_satisfaction.to_f).round(2)
  end

  def _surveys_source_satisfaction
    count = @surveys_source_satisfactions.size
    total = @surveys_source_satisfactions.reduce(0) do | sum, satisfaction |
      sum + satisfaction.second
    end
    average = total.to_f / count.to_f
    (average / 5).round(2)
  end

  def _surveys_source_satisfaction_from_best
    (_initial_source_satisfaction / @common_info.best_satisfaction.to_f).round(2)
  end

  def _surveys_source_satisfaction_by_speciality
    @surveys_source_satisfactions
  end

  def _surveys_source_satisfaction_by_speciality
    satisfaction_by_speciality = {}
    @surveys_source_satisfactions.each do | speciality, score |
      satisfaction_by_speciality[speciality] = [] if satisfaction_by_speciality[speciality].nil?
      satisfaction_by_speciality[speciality] << score
    end

    satisfaction_by_speciality = satisfaction_by_speciality.map do | speciality, satisfaction |
      {name: speciality, score: satisfaction.sum / satisfaction.size}
    end
  end

  def _has_initial_source_satisfaction_information
    @branch.provider.satisfactions.present?
  end

  def _has_surveys_source_satisfaction_information
    @surveys_source_satisfactions.present?
  end

  def _response
    {
      initial_source: {
        source: 'initial',
        satisfaction: _initial_source_satisfaction,
        satisfaction_from_best: _initial_source_satisfaction_from_best,
        has_satisfaction_information: _has_initial_source_satisfaction_information
      },
      surveys_source: {
        source: 'surveys',
        satisfaction: _surveys_source_satisfaction,
        satisfaction_from_best: _surveys_source_satisfaction_from_best,
        satisfaction_by_speciality: _surveys_source_satisfaction_by_speciality,
        has_satisfaction_information: _has_surveys_source_satisfaction_information,
      }
    }
  end
end
