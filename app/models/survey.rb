class Survey < ActiveRecord::Base
  belongs_to :branch
  default_scope { order(created_at: :asc) }
  after_save :update_quality
  after_save :update_waiting_times

  private

  def update_quality
    return unless step_id == 15
    CalculateQualityWorker.perform_async(branch_id)
  end

  def update_waiting_times
    return unless step_id == 5
    CalculateWaitingTimesWorker.perform_async(branch_id)
  end
end
