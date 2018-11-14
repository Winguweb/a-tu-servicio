# To be use in an initialize as a singleton
class SurveyData
  Step = Struct.new(:id, :question, :multi_response, :answers)
  Answer = Struct.new(:id, :label, :value)

  attr_reader :response_structure

  RESPONSE_STRUCTURE_KEYS = [
    {
      id: 1
    },
    {
      id: 2,
      keys: 'answers',
      detail_ids: [5, 7, 9, 10]
    },
    {
      id: 11,
      keys: 'answers',
      detail_ids: [12, 13, 14]
    },
    {
      id: 15,
      detail_ids: [16, 17]
    }
  ].freeze
  private_constant :RESPONSE_STRUCTURE_KEYS

  def initialize(steps:)
    @steps_by_id = steps.index_by{|s| s[:id]}
    @response_structure = {}
    process_response_structure
  end

  private

  def process_response_structure
    RESPONSE_STRUCTURE_KEYS.each do |node|
      node_id = node[:id]
      detail_ids = node[:detail_ids]

      @response_structure[node_id] = {}

      if node.key?(:keys)
        @response_structure[node_id] = process_answers_with_detail(node_id, detail_ids)
      else
        @response_structure[node_id][:answers] = process_answers_of(node_id)
        @response_structure[node_id][:detail] = process_detail_for(detail_ids) if detail_ids
      end
    end
  end

  def process_answers_with_detail(node_id, detail_ids)
    @steps_by_id[node_id][:answers].each_with_object({}) do |answer_data, _hash|
      answer = Answer.new(answer_data[:id], answer_data[:label], answer_data[:value])

      _hash[answer.id] = {
        counter: 0,
        percentage: 0.0,
        detail: process_detail_for(detail_ids)
      }
    end
  end

  def process_answers_of(node_id)
    answers_data = @steps_by_id[node_id][:answers]

    # TO-DO: Review this id vote_data.yml file change. Because I need to do
    # this only because of the step 5 that has different answers depending on
    # the id of the previous step
    if node_id == 5
      answers_data = answers_data.first[:answers]
    end

    answers_data.each_with_object({}) do |answer_data, _hash|
      answer = Answer.new(answer_data[:id], answer_data[:data][:label], answer_data[:data][:value])

      _hash[answer.id] = { counter: 0, percentage: 0.0 }
    end
  end

  def process_detail_for(detail_ids)
    detail_ids.each_with_object({}) do |node_id, _hash|
      _hash[node_id] = {}
      _hash[node_id][:answers] = process_answers_of(node_id)
    end
  end
end
