class SurveysMetricsService
  attr_reader :response

  def self.call(branch)
    return new(branch)
  end

  def initialize(branch)
    @branch = branch
    @surveys_by_client_id = Survey.where(branch_id: branch.id).group_by(&:client_id)
    @response = $survey_data.response_structure

    populate_response
  end

  private

  def populate_response
    @surveys_by_client_id.each do |client_id, survey_responses|
      client_survey = ClientSurvey.new(survey_responses)

      client_survey.add_responses_to(@response)
    end
  end

  class ClientSurvey
    def initialize(survey_responses)
      @survey_responses = survey_responses
    end

    def add_responses_to(response)

    end
  end
end
