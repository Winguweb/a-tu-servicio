class ProvidersController < ApplicationController
  autocomplete :provider, :search_name, full: true, limit: 15

  def index
    @providers = Provider.where("name ILIKE ?", "%#{params[:q]}%")
    render json: @providers
  end
end
