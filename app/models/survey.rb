class Survey < ActiveRecord::Base
  belongs_to :branch
  default_scope { order(created_at: :asc) }
  after_save :update_quality

  private

  def update_quality
    return unless step_id == 15
    CalculateQualityWorker.perform_async(branch_id)
  end
end
