class BranchesController < ApplicationController

  def index
    @branches = Branch.includes(:provider).where("name ILIKE ?", "%#{params[:q]}%")
    render json: @branches
  end
end
