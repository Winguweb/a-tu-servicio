class SurveysMetricsService
  attr_reader :response

  def self.call(branch)
    return new(branch)
  end

  def initialize(branch)
    @branch = branch
    @surveys_by_client_id = Survey.where(branch_id: @branch.id).group_by(&:client_id)
    @response = $survey_data.response_structure

    populate_response
  end

  private

  def populate_response
    return @response

    @surveys_by_client_id.each do |client_id, survey_responses|
      client_survey = ClientSurvey.new(survey_responses)

      client_survey.add_responses_to(@response)
    end
  end

  def calculate_percentages_on_response

  end

  # Support Class
  class ClientSurvey
    def initialize(survey_responses)
      @survey_responses = survey_responses
      @structure_keys = SurveyData.response_structure_keys
    end

    def add_responses_to(response)
      @structure_keys.each do |node|
        node_id = node[:id]
        detail_ids = node[:detail_ids]

        step_responses = if !!node[:multiple]
          [{}]
        else
          {
            node_id => @survey_responses.detect{|r| r.step_id == node_id }
          }.tap do |_hash|
            Array(detail_ids).each do |detail_id|
              _hash[detail_id] = @survey_responses.detect{|r| r.step_id == detail_id }
            end
          end
        end

        if node.key?(:keys)

        else
          visitor_response = step_responses[node_id]
          add_anwser_count_to(response[node_id], visitor_response.answer_id)
        end
      end
    end

    def add_anwser_count_to(node_response, answer_id)
      node_response[:answers][answer_id][:counter] += 1
    end

  end
end
