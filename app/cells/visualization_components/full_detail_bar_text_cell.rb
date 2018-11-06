class VisualizationComponents::FullDetailBarTextCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def range
    model || []
  end

end
