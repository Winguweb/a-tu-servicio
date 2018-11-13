class VisualizationComponents::FullDetailBarTextCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def explanation
    model || []
  end

end
