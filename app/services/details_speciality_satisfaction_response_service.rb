class DetailsSpecialitySatisfactionResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, 'app', 'cells', 'components', 'vote_modal', 'vote_data.yml'))
    @branch = branch
    @surveys_source_speciality_satisfaction = _get_survey_source_speciality_satisfaction
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _get_survey_source_speciality_satisfaction
    surveys = _select_survey_attributes
    surveys = _from_this_branch_and_step(surveys)
    surveys = _grouped_by_client(surveys)
    surveys = _return_answer_value(surveys)
  end

  def _select_survey_attributes
    Survey.select('client_id, answer_id, answer_data, question_value, step_id')
  end

  def _from_this_branch_and_step(surveys)
    surveys.where(branch_id: @branch.id).where(step_id: @surveys_structure['structure']['speciality_satisfaction'])
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

  def _get_speciality_satisfaction_count_by_speciality
    rating_map = [:very_bad, :bad, :acceptable, :good, :very_good]
    @surveys_source_speciality_satisfaction.each_with_object(Hash.new({})) do | word, counts |
      speciality = word.first
      rating = rating_map[word.second - 1]
      explanation = word.third
      counts[speciality] = {ratings: {very_bad: 0, bad: 0, acceptable: 0, good: 0, very_good: 0}} if counts[speciality].blank?

      counts[speciality][:ratings][rating] += 1

      counts[speciality][:explanations] = {} if counts[speciality][:explanations].blank?
      counts[speciality][:explanations][explanation] = 0 if counts[speciality][:explanations][explanation].blank?
      counts[speciality][:explanations][explanation] += 1
    end
  end

  def _get_total_speciality_satisfaction(speciality)
     _get_speciality_satisfaction_count_by_speciality[speciality][:ratings].values.sum
  end

  def _get_total_explanations(explanations)
     explanations.sum do | explanation |
      explanation.second
     end
  end

  def _get_speciality_satisfaction_count_over_total
    _get_speciality_satisfaction_count_by_speciality.map do | speciality_satisfaction |
      speciality = speciality_satisfaction.first
      return {
        name: speciality,
        percentage: 0,
        explanations: [],
      } if _get_total_speciality_satisfaction(speciality) == 0
      {
        name: speciality,
        percentage: {
          very_bad: (speciality_satisfaction.second[:ratings][:very_bad].to_f / _get_total_speciality_satisfaction(speciality) * 100).round(2),
          bad: (speciality_satisfaction.second[:ratings][:bad].to_f / _get_total_speciality_satisfaction(speciality) * 100).round(2),
          acceptable: (speciality_satisfaction.second[:ratings][:acceptable].to_f / _get_total_speciality_satisfaction(speciality) * 100).round(2),
          good: (speciality_satisfaction.second[:ratings][:good].to_f / _get_total_speciality_satisfaction(speciality) * 100).round(2),
          very_good: (speciality_satisfaction.second[:ratings][:very_good].to_f / _get_total_speciality_satisfaction(speciality) * 100).round(2),
        },
        explanation: speciality_satisfaction.second[:explanations].map do | explanation |
          {
            name: explanation.first,
            percentage: (explanation.second.to_f / _get_total_explanations(speciality_satisfaction.second[:explanations]) * 100).round(2)
          }
        end
      }
    end
  end

  def _response
    {
      details: {
        speciality_satisfaction: _get_speciality_satisfaction_count_over_total
      }
    }
  end
end
