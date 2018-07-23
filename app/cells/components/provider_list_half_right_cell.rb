class Components::ProviderListHalfRightCell < Cell::ViewModel
  include StatisticsHelper

  private

  def providers
    model || nil
  end
end
