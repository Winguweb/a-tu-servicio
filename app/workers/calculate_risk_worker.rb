class CalculateRiskWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    survey_data = Survey.where(branch_id: branch.id, question_subtype: 'risk')
    total_points = survey_data.length * 5
    
    puts 'risk worker'
    puts total_points.to_s

    risk_sum = 0
    survey_data.sum do | survey |
      puts 'on loop'
      puts survey['id']
      puts survey["answer_data"]
      puts 'add!'
      risk_sum = risk_sum + survey["answer_data"]["value"]
    end

    risk_sum = risk_sum.to_f
    risk_total_average = total_points > 0 ? risk_sum / total_points : 0    
    risk_total_average = (risk_total_average / 2) * 10

    $redis.set("risk/branch/#{branch_id}", risk_total_average.round(half: 'down'))
    puts risk_sum.to_s
    puts risk_total_average.to_s
  end
end
