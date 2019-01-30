class CalculateSatisfactionWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    surveys_metrics = SurveysMetricsService.call(branch)
    specialities = surveys_metrics.response[2]

    average_by_speciality = []

    satisfactions_total_count = 0

    specialities.each do | k, speciality |
      satisfactions = speciality[:detail][7][:answers]

      satisfactions_sum = satisfactions.sum do | k, satisfaction |
        satisfaction[:counter] * k
      end

      satisfactions_count = satisfactions.sum do | k, satisfaction |
        satisfaction[:counter]
      end.to_f

      satisfactions_average = satisfactions_count > 0 ? satisfactions_sum / satisfactions_count : 0
      average_by_speciality << satisfactions_average
      satisfactions_total_count += 1 if satisfactions_count > 0
    end

    satisfactions_total_sum = average_by_speciality.sum.to_f

    satisfactions_total_average = satisfactions_total_count > 0 ? satisfactions_total_sum / satisfactions_total_count : 0

    $redis.set("satisfaction/branch/#{branch_id}", satisfactions_total_average)
  end
end
