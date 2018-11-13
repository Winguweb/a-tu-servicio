class DetailsSpecialitySatisfactionExplanationResponseService
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
    surveys.where(branch_id: @branch.id).where(step_id: @surveys_structure['structure']['speciality_satisfaction_explanation'])
  end

  def _grouped_by_client(surveys)
    surveys.group_by{ | survey | survey.client_id }
  end

  def _return_answer_value(surveys)
    a = surveys.values.map do | answers |
      {
        speciality: answers.first[:answer_data]["label"],
        explanations: answers.second ? {
          text: answers.second[:answer_data]['value'],
          type: answers.second[:step_id] == 10 ? 'good' : 'bad'
        } : nil
      }
    end
  end

  def _get_speciality_satisfaction_count_by_speciality
    a = @surveys_source_speciality_satisfaction.each_with_object(Hash.new({})) do | word, counts |
      next if word[:explanations].blank?
      type = word[:explanations][:type]
      speciality = word[:speciality]
      explanation = word[:explanations][:text]
      counts[speciality] = {} if counts[speciality].blank?
      counts[speciality][type] = {} if counts[speciality][type].blank?
      counts[speciality][type][explanation] = 0 if counts[speciality][type][explanation].blank?
      counts[speciality][type][explanation] += 1
    end
  end

  def _get_total_speciality_satisfaction_by_type(type, speciality)
    return 0 if _get_speciality_satisfaction_count_by_speciality[speciality][type].blank?
    _get_speciality_satisfaction_count_by_speciality[speciality][type].values.sum
  end

  def _get_total_explanations(explanations)
     explanations.sum do | explanation |
      explanation.second
     end
  end

  def _extract_expectations_by_type(type, speciality, explanations)
    return [] if explanations[type].blank?
    explanations[type].map do | explanation |
      if _get_total_speciality_satisfaction_by_type(type, speciality) == 0
        percentage = 0
      else
        percentage = (explanation.second.to_f / _get_total_speciality_satisfaction_by_type(type, speciality) * 100).round(2)
      end
      {
        name: explanation.first,
        percentage: percentage
      }
    end
  end

  def _get_speciality_satisfaction_count_over_total
    _get_speciality_satisfaction_count_by_speciality.map do | speciality_satisfaction |
      speciality = speciality_satisfaction.first
      explanations = speciality_satisfaction.second
      {
        name: speciality,
        explanations: {
          good: _extract_expectations_by_type("good", speciality, explanations),
          bad: _extract_expectations_by_type("bad", speciality, explanations),
        }
      }
    end
  end

  def _response
    {
      details: {
        speciality_satisfaction_explanations: _get_speciality_satisfaction_count_over_total
      }
    }
  end
end
