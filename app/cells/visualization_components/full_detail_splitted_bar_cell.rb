class VisualizationComponents::FullDetailSplittedBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def percentage
    model || []
  end

  def label
    options[:label]
  end

end
