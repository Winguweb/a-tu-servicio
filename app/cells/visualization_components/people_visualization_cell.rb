class VisualizationComponents::PeopleVisualizationCell < Cell::ViewModel
  include StatisticsHelper

  private

  def count
    model || 0
  end
end
