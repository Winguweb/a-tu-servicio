class Components::BranchDetailHalfRightCell < Cell::ViewModel
  include StatisticsHelper

  private

  def branch
    model || nil
  end
end
