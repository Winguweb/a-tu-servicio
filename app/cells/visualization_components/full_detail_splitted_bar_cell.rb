class VisualizationComponents::FullDetailSplittedBarCell < Cell::ViewModel
  # include StatisticsHelper

  private

  def step
    @step = options[:step]
  end

  def label
    @label ||= options[:label]
  end

  def percentage
    model || {}
  end

  def reverse
    return @reverse if defined?(@reverse)

    @reverse = options[:reverse] || false
  end

end
