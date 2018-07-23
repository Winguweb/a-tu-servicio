class BranchesController < ApplicationController

  def index
    @branches = Branch.includes(:provider).where("name ILIKE ?", "%#{params[:q]}%")
    render json: @branches
  end

  def show
    @branch = Branch.find_by(id: params[:id])
    render json: @branch
  end
end
