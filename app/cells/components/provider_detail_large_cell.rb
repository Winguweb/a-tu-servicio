class Components::ProviderDetailLargeCell < Cell::ViewModel
  include StatisticsHelper

  private

  def providers
    model || nil
  end
end
