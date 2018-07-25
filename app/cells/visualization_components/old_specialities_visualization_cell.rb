class VisualizationComponents::SpecialitiesVisualizationCell < Cell::ViewModel
  include StatisticsHelper

  private

  def common_info
    model.to_json || nil
  end
end
