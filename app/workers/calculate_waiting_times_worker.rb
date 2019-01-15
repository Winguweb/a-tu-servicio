class CalculateWaitingTimesWorker
  include Sidekiq::Worker

  def perform(branch_id)
    waiting_times_surveys = Survey.where(branch_id: branch_id, step_id: 5)
    count = waiting_times_surveys.size
    total = waiting_times_surveys.pluck("answer_data").pluck("value").sum
    waiting_times = total / count if count > 0
    $redis.set("waiting_times/branch/#{branch_id}", waiting_times)
  end
end
