class FlagResponseService
  def initialize(branch)
    @branch = branch
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _has_waiting_times_information
    @waiting_times.present?
  end

  def _has_satisfaction_information
    @satisfactions.present?
  end

  def _has_specialities_information
    @specialities.present?
  end

  def _response
    @specialities = @branch.specialities
    @satisfactions = @branch.provider.satisfactions
    @waiting_times = @branch.provider.waiting_times
    {
      has_waiting_times_information: _has_waiting_times_information,
      has_satisfaction_information: _has_satisfaction_information,
      has_specialities_information: _has_specialities_information,
    }
  end
end
