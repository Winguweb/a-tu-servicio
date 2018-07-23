class Components::BranchListLargeCell < Cell::ViewModel
  include StatisticsHelper

  private

  def branches
    model || nil
  end
end
