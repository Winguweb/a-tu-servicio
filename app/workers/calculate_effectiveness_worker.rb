class CalculateEffectivenessWorker
  include Sidekiq::Worker

  def perform(branch_id)
    branch = Branch.find_by(id: branch_id)
    survey_data = Survey.where(branch_id: branch.id, question_subtype: 'effectiveness')
    total_points = survey_data.length * 5
    
    puts 'effectiveness worker'
    puts total_points.to_s

    effectiveness_sum = 0
    survey_data.sum do | survey |
      puts 'on loop'
      puts survey['id']
      puts survey["answer_data"]
      puts 'add!'
      effectiveness_sum = effectiveness_sum + survey["answer_data"]["value"]
    end

    effectiveness_sum = effectiveness_sum.to_f
    effectiveness_total_average = total_points > 0 ? effectiveness_sum / total_points : 0    
    effectiveness_total_average = (effectiveness_total_average / 2) * 10

    $redis.set("effectiveness/branch/#{branch_id}", effectiveness_total_average.round(half: 'down'))
    puts effectiveness_sum.to_s
    puts effectiveness_total_average.to_s
  end
end
