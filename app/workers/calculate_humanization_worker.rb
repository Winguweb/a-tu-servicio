class CalculateHumanizationWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    surveys_metrics = SurveysMetricsService.call(branch)
    specialities = surveys_metrics.response[11]

    average_by_speciality = []

    humanizations_total_count = 0

    specialities.each do | k, speciality |
      humanizations = speciality[:detail][12][:answers]

      humanizations_sum = humanizations.sum do | k, humanization |
        humanization[:counter] * k
      end

      humanizations_count = humanizations.sum do | k, humanization |
        humanization[:counter]
      end.to_f

      humanizations_average = humanizations_count > 0 ? humanizations_sum / humanizations_count : 0
      average_by_speciality << humanizations_average
      humanizations_total_count += 1 if humanizations_count > 0
    end

    humanizations_total_sum = average_by_speciality.sum.to_f

    humanizations_total_average = humanizations_total_count > 0 ? humanizations_total_sum / humanizations_total_count : 0

    $redis.set("humanization/branch/#{branch_id}", humanizations_total_average)
  end
end
