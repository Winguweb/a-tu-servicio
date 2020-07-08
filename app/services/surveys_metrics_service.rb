class SurveysMetricsService
  attr_reader :response

  def self.call(branch)
    return new(branch)
  end

  def initialize(branch)
    @branch = branch
    @surveys_by_client_id = Survey.where(branch_id: @branch.id).group_by(&:client_id)

    # SurveyData $survey_data
    # $survey_data.response_structure es estructura con contadores
    @response = $survey_data.response_structure

    # puts @response
    populate_response
  end

  private

  def populate_response
    @surveys_by_client_id.each do |client_id, survey_responses|
      client_survey = ClientSurvey.new(survey_responses)

      client_survey.add_responses_to(@response)
    end

    calculate_percentages_on_response
  end

  def calculate_percentages_on_response
    metrics_response_structure = SurveyData.response_structure_keys

    metrics_response_structure.each do |node|
      node_id = node[:id]
      detail_ids = node[:detail_ids]

      if node.key?(:keys)
        process_answers_percentages_with_detail_of(@response[node_id], detail_ids)
      else
        process_answers_percentage_of(@response[node_id])
        if detail_ids
          process_detail_answers_percentage_of(@response[node_id], detail_ids)
        end
      end
    end
  end

  def process_answers_percentages_with_detail_of(response_node, detail_ids)
    response_node_dup = response_node.deep_dup
    answers = response_node_dup.values

    total_answers_count = answers.map{|data| data[:counter]}.sum

    response_node_dup.each do |answer_id, data|
      counter = data[:counter]

      percentage = if counter == 0
        0.0
      else
        (counter.to_f/total_answers_count.to_f * 100.0).round(1)
      end

      response_node[answer_id][:percentage] = percentage
      if detail_ids
        process_detail_answers_percentage_of(response_node[answer_id], detail_ids)
      end
    end
  end

  def process_answers_percentage_of(response_node)
    answers = response_node[:answers].deep_dup

    total_answers_count = answers.values.map{|data| data[:counter]}.sum

    answers.each do |answer_id, data|
      counter = data[:counter]
      next if counter == 0

      percentage = (counter.to_f/total_answers_count.to_f * 100.0).round(1)

      response_node[:answers][answer_id][:percentage] = percentage
    end
  end

  def process_detail_answers_percentage_of(response_node, detail_ids)
    Array(detail_ids).each do |node_id|
      process_answers_percentage_of(response_node[:detail][node_id])
    end
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

        node_responses_groups = build_responses_groups(node_id, detail_ids, !!node[:multiple])

        if node.key?(:keys)
          node_responses_groups.each do |node_responses|
            add_answers_count_with_detail_for(response[node_id], node_id, detail_ids, node_responses)
          end
        else
          node_responses_groups.each do |node_responses|
            add_answer_count_to(response[node_id], node_responses[node_id])
            if detail_ids
              add_detail_answers_count_for(response[node_id], detail_ids, node_responses)
            end
          end
        end
      end
    end

    def add_answers_count_with_detail_for(response_node, node_id, detail_ids, node_responses)
      node_response = node_responses[node_id]

      return unless node_response && node_response.respond_to?(:answer_id)

      response_node[node_response.answer_id][:counter] += 1 if response_node[node_response.answer_id].present?

      add_detail_answers_count_for(response_node[node_response.answer_id], detail_ids, node_responses)
    end

    def add_answer_count_to(response_node, node_response)
      return unless node_response && node_response.respond_to?(:answer_id)

      response_node[:answers][node_response.answer_id][:counter] += 1
    end

    def add_detail_answers_count_for(response_node, detail_ids, node_responses)
      return if response_node.blank?
      Array(detail_ids).each do |node_id|
        add_answer_count_to(response_node[:detail][node_id], node_responses[node_id])
      end
    end

    def build_responses_groups(node_id, detail_ids, multiple)
      if multiple
        response_group = {}
        within_group = false
        # TO-DO: All this logic below is very order sensitive of the records
        # the assumptions is that the grouped records are next to each other
        @survey_responses.each_with_object([]) do |survey_response, _array|
          if survey_response.step_id == node_id
            if within_group
              _array << response_group
              within_group = false
            end
            response_group = {}
            response_group[node_id] = survey_response
            within_group = true

            next
          end

          if Array(detail_ids).include?(survey_response.step_id)
            response_group[survey_response.step_id] = survey_response
          elsif within_group
            _array << response_group
            within_group = false
          end
        end
        # END | TO-DO
      else
        [
          {
            node_id => @survey_responses.detect{|r| r.step_id == node_id }
          }.tap do |_hash|
            Array(detail_ids).each do |detail_id|
              _hash[detail_id] = @survey_responses.detect{|r| r.step_id == detail_id }
            end
          end
        ]
      end
    end
  end
end
