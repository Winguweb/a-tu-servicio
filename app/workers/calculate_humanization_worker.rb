class CalculateHumanizationWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    survey_data = Survey.where(branch_id: branch.id, question_subtype: 'humanization')
    total_points = survey_data.length * 5
    
    puts 'humanization worker'
    puts total_points.to_s

    humanization_sum = 0
    survey_data.sum do | survey |
      puts 'on loop'
      puts survey['id']
      puts survey["answer_data"]
      puts 'add!'
      humanization_sum = humanization_sum + survey["answer_data"]["value"]
    end

    humanization_sum = humanization_sum.to_f
    humanizations_total_average = total_points > 0 ? humanization_sum / total_points : 0    
    # surveys_metrics = SurveysMetricsService.call(branch)
    # specialities = surveys_metrics.response[11]

    # average_by_speciality = []

    # humanizations_total_count = 0

    # specialities.each do | k, speciality |
    #   humanizations = speciality[:detail][12][:answers]

    #   humanizations_sum = humanizations.sum do | k, humanization |
    #     humanization[:counter] * k
    #   end

    #   humanizations_count = humanizations.sum do | k, humanization |
    #     humanization[:counter]
    #   end.to_f

    #   humanizations_average = humanizations_count > 0 ? humanizations_sum / humanizations_count : 0
    #   average_by_speciality << humanizations_average
    #   humanizations_total_count += 1 if humanizations_count > 0
    # end

    # humanizations_total_sum = average_by_speciality.sum.to_f

    # humanizations_total_average = humanizations_total_count > 0 ? humanizations_total_sum / humanizations_total_count : 0
    humanizations_total_average = (humanizations_total_average / 2) * 10

    $redis.set("humanization/branch/#{branch_id}", humanizations_total_average.round(half: 'down'))
    puts humanization_sum.to_s
    puts humanizations_total_average.to_s
  end
end
