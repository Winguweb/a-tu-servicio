class VisualizationComponents::FullDetailSplittedBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def percentage
    model || []
  end

end
