class Components::ProviderListLargeCell < Cell::ViewModel
  include StatisticsHelper

  private

  def providers
    model || nil
  end
end
