class WaitingTimeResponseService
  include Singleton

  def initialize(branch)
    @branch = branch
    @waiting_times = @branch.provider.waiting_times
    @common_info = CommonInfoService.call
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _waiting_times_total
    @waiting_times.reduce(0){ |last, w| last + w.days }
  end

  # Used for percentage/volume bar number
  def _waiting_times_average
    (_waiting_times_total.to_f / @waiting_times.count.to_f).round(1)
  end

  # Used for percentage/volume bar width
  def _waiting_times_percentage_from_worst
    (_waiting_times_total.to_f / @common_info.worst_total_waiting_times.to_f).round(2)
  end

  def _waiting_time_from_best(waiting_time)
    (waiting_time.days.to_f / @common_info.best_waiting_times[waiting_time.name].to_f).round(2)
  end

  def _waiting_time_name(waiting_time)
    waiting_time.name
  end

  def _waiting_time_days(waiting_time)
    waiting_time.days.to_f
  end

  def _waiting_times_response
    @waiting_times.order(name: :asc).map do |waiting_time|
      # Percentage relation between actual branch provider's waiting times and worst provider's waiting times
      {
        name: _waiting_time_name(waiting_time),
        days: _waiting_time_days(waiting_time),
        from_best: _waiting_time_from_best(waiting_time)
      }
    end
  end

  def _response
    {
      initial_source: {
        waiting_times: _waiting_times_response,
        waiting_times_average: _waiting_times_average,
        waiting_times_percentage_from_worst: _waiting_times_percentage_from_worst,
      },
      surveys_source: {
        waiting_times: _waiting_times_response,
        waiting_times_average: _waiting_times_average,
        waiting_times_percentage_from_worst: _waiting_times_percentage_from_worst,
      }
    }
  end
end
