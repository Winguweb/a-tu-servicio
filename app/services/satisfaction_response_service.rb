class SatisfactionResponseService
  include Singleton

  def initialize(branch)
    @surveys_structure = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml"))
    @branch = branch
    @initial_source_satisfactions = @branch.provider.satisfactions
    @surveys_source_satisfactions = Survey
      .select('client_id, answer_id, answer_data, question_value, step_id')
      .where(
        branch_id: @branch.id,
        step_id: @surveys_structure['structure']['waiting_times']
      )
      .group_by{ |survey|
        survey.client_id
      }.values.map do |waiting_time|
        waiting_time.pluck(:answer_data).map do |answer_data|
          answer_data['value']
        end
      end


    # @surveys_source_satisfactions.each do |survey|
    #   @surveys_structure['structure'].each do |group|
    #     binding.pry
    #   end
    # end

    @common_info = CommonInfoService.call
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _initial_source_satisfaction
    (@initial_source_satisfactions.present? ? @initial_source_satisfactions.first.percentage.to_f : 0.0).round(2)
  end

  def _initial_source_satisfaction_from_best
    (_initial_source_satisfaction / @common_info.best_satisfaction.to_f).round(2)
  end

  def _surveys_source_satisfaction
    @surveys_source_satisfactions
  end

  def _surveys_source_satisfaction_from_best
    (_initial_source_satisfaction / @common_info.best_satisfaction.to_f).round(2)
  end

  def _response
    {
      initial_source: {
        satisfaction: _initial_source_satisfaction,
        satisfaction_from_best: _initial_source_satisfaction_from_best,
      },
      surveys_source: {
        satisfaction: _surveys_source_satisfaction,
        satisfaction_from_best: _surveys_source_satisfaction_from_best,
      }
    }
  end
end
