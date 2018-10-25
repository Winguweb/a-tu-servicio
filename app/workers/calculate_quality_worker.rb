class CalculateQualityWorker
  include Sidekiq::Worker

  def perform(branch_id)
    quality_surveys = Survey.where(branch_id: branch_id, step_id: 15)
    count = quality_surveys.size
    total = quality_surveys.pluck("answer_data").pluck("value").sum
    quality = total / count if count > 0
    $redis.set("quality/branch/#{branch_id}", quality)
  end
end
