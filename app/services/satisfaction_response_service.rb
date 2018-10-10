class SatisfactionResponseService
  include Singleton

  def initialize(branch)
    @branch = branch
    @satisfactions = @branch.provider.satisfactions
    @common_info = CommonInfoService.call
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _satisfaction
    (@satisfactions.present? ? @satisfactions.first.percentage.to_f : 0.0).round(2)
  end

  def _satisfaction_from_best
    (_satisfaction / @common_info.best_satisfaction.to_f).round(2)
  end

  def _response
    {
      initial_source: {
        satisfaction: _satisfaction,
        satisfaction_from_best: _satisfaction_from_best,
      },
      surveys_source: {
        satisfaction: _satisfaction,
        satisfaction_from_best: _satisfaction_from_best,
      }
    }
  end
end
