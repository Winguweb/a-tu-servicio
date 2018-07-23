class Components::BranchDetailLargeCell < Cell::ViewModel
  include StatisticsHelper

  private

  def branch
    model || nil
  end
end
