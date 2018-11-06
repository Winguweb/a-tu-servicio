class VisualizationComponents::FullDetailBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def ranges
    model || []
  end

  def layout
    'layout' if options[:layout]
  end

end
