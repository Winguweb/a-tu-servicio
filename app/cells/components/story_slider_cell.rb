class Components::StorySliderCell < Cell::ViewModel
  include StatisticsHelper

  private

  def common_info
    model || nil
  end
end
