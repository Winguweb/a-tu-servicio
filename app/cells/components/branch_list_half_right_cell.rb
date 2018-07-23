class Components::BranchListHalfRightCell < Cell::ViewModel
  include StatisticsHelper

  private

  def branches
    model || nil
  end
end
