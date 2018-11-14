class VisualizationComponents::FullDetailBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def percentage
    model || []
  end

end
