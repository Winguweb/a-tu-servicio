class CalculateWaitingTimesWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    surveys_metrics = SurveysMetricsService.call(branch)
    specialities = surveys_metrics.response[2]

    average_by_speciality = []

    waiting_times_total_count = 0

    specialities.each do | k, speciality |
      waiting_times = speciality[:detail][5][:answers]

      waiting_times_sum = waiting_times.sum do | k, waiting_time |
        waiting_time[:counter] * k
      end

      waiting_times_count = waiting_times.sum do | k, waiting_time |
        waiting_time[:counter]
      end.to_f

      waiting_times_average = waiting_times_count > 0 ? waiting_times_sum / waiting_times_count : 0
      average_by_speciality << waiting_times_average
      waiting_times_total_count += 1 if waiting_times_count > 0
    end

    waiting_times_total_sum = average_by_speciality.sum.to_f

    waiting_times_total_average = waiting_times_total_count > 0 ? waiting_times_total_sum / waiting_times_total_count : 0

    $redis.set("waiting_times/branch/#{branch_id}", waiting_times_total_average / 3 * 5)
  end
end
