class VisualizationComponents::FullDetailBarTextCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def percentage
    model || []
  end

  def label
    options[:label]
  end

  def color
    options[:color]
  end

end
