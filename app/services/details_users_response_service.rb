class DetailsUsersResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml"))
    @branch = branch
    @surveys_source_user_types = _get_survey_source_user_types
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _get_survey_source_user_types
    surveys = _select_survey_attributes
    surveys = _from_this_branch_and_step(surveys)
    surveys = _grouped_by_client(surveys)
    surveys = _return_answer_value(surveys)
  end

  def _select_survey_attributes
    Survey.select('client_id, answer_id, answer_data, question_value, step_id')
  end

  def _from_this_branch_and_step(surveys)
    surveys.where(branch_id: @branch.id)
    .where(step_id: @surveys_structure['structure']['user_type'])
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

  def _get_users_count_by_type
    @surveys_source_user_types.each_with_object(Hash.new(0)) do | word, counts |
      counts[word.first] += 1
    end
  end

  def _get_total_users
    @surveys_source_user_types.count
  end

  def _get_user_types_count_over_total
    _get_users_count_by_type.map do | user_by_type |
      return {
        name: user_by_type.first,
        percentage: 0
      } if _get_total_users == 0
      {
        name: user_by_type.first,
        percentage: (user_by_type.second.to_f / _get_total_users * 100).round(2)
      }
    end
  end

  def _response
    {
      details: {
        user_types: _get_user_types_count_over_total
      }
    }
  end
end
