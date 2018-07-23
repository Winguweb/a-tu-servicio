class Components::BranchDetailHalfLeftCell < Cell::ViewModel
  include StatisticsHelper

  private

  def branch
    model || nil
  end
end
