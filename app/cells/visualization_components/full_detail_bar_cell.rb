class VisualizationComponents::FullDetailBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def ranges
    model || []
  end

end
