class BranchesController < ApplicationController

  def index

    @branches = Branch.includes(:provider).where("branches.name ILIKE ?", "%#{params[:q]}%")
    @response = @branches.map do |branch|
      {
        :id => branch.id,
        :name => branch.name,
        :address => branch.address,
        :provider_name => branch.provider.name
      }
    end
    render json: @response
  end

  def show
    @common_info = CommonInfoService.call
    @branch = Branch.includes(:provider, :beds).find_by(id: params[:id])
    @beds_count = @branch.beds.reduce(0) {|last, bed| last += bed[:quantity]}
    satisfaction = (s = @branch.provider.satisfactions.first).nil? ? nil : s.percentage.to_f
    satisfaction_from_best = satisfaction.nil? ? nil : (satisfaction / @common_info.best_satisfaction.to_f).round(2)
    @response = {
      :id => @branch.id,
      :name => @branch.name,
      :address => @branch.address,
      :provider_name => @branch.provider.name,
      :satisfaction => satisfaction,
      :satisfaction_from_best => satisfaction_from_best,
      :beds => @branch.beds.map do |bed|
        {
          :area => bed.area,
          :quantity => bed.quantity,
          :from_best => (bed.quantity.to_f/@common_info.best_beds[bed.area].to_f).round(2)
        }
      end
    }
    render json: @response
  end
end
