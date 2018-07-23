class Components::ProviderDetailHalfLeftCell < Cell::ViewModel
  include StatisticsHelper

  private

  def provider
    model || nil
  end
end
