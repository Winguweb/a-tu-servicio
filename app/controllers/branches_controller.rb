class BranchesController < ApplicationController

  def index
    query = params[:q]
    page = params[:page]
    search_service = SearchService.call
    @branches = query.blank? ? search_service.search('*', page) : search_service.search(query, page)

    @response = {
      :results => @branches.map do |branch|
        {
          :id => branch.id,
          :name => branch.name,
          :address => branch.address,
          :provider_name => branch.provider.name,
          :featured => branch.provider.featured
        }
      end
    }
    render json: @response
  end

  def show
    @common_info = CommonInfoService.call
    @branch = Branch.includes(:provider, :beds, :specialities).find_by(id: params[:id])
    @beds_count = @branch.beds.reduce(0) {|last, bed| last += bed[:quantity]}
    @surveys = Survey.where(branch_id: @branch.id)

    satisfaction = (s = @branch.provider.satisfactions.first).nil? ? nil : s.percentage.to_f
    # Used for icon bar graph
    satisfaction_from_best = satisfaction.nil? ? nil : (satisfaction / @common_info.best_satisfaction.to_f).round(2)

    user_waiting_times = {}


    # TODO: WIP
    @surveys.where(step_id: 6).each do |waiting_time|
      speciality = @surveys.where(step_id: 2, client_id: waiting_time.client_id).first.answer_value
      user_waiting_times[speciality] = 0 if user_waiting_times[speciality].blank?
      user_waiting_times[speciality] += waiting_time.answer_value.to_i
    end

    waiting_times_total = @branch.provider.waiting_times.reduce(0){|last, w| last + w.days}
    # Used for percentage/volume bar number
    waiting_times_average = (waiting_times_total.to_f/@branch.provider.waiting_times.count.to_f).round(1)
    # Used for percentage/volume bar width
    waiting_times_percentage_from_worst = waiting_times_total / @common_info.worst_total_waiting_times.to_f
    @response = {
      :id => @branch.id,
      :name => @branch.name,
      :address => @branch.address,
      :provider => {
        name: @branch.provider.name,
        subnet: @branch.provider.subnet,
        address: @branch.provider.address,
        website: @branch.provider.website,
        communication_services: @branch.provider.communication_services
      },
      :satisfaction => satisfaction,
      :satisfaction_from_best => satisfaction_from_best,
      :has_waiting_times_information => !@branch.provider.waiting_times.blank?,
      :has_beds_information => !@branch.beds.blank?,
      :has_satisfaction_information => !@branch.provider.satisfactions.blank?,
      :has_specialities_information => !@branch.specialities.blank?,
      :specialities => @branch.specialities.map do |speciality|
        {
          name: speciality.name,
        }
      end,
      :specialities_count => @branch.specialities.count,
      :user_waiting_times => user_waiting_times,
      :waiting_times => @branch.provider.waiting_times.order(name: :asc).map do |waiting_time|
        # Percentage relation between actual branch provider's waiting times and worst provider's waiting times
        from_best = (waiting_time.days.to_f/@common_info.best_waiting_times[waiting_time.name].to_f).round(2)
        {
          :name => waiting_time.name,
          :days => waiting_time.days.to_f,
          :from_best => from_best
        }
      end,
      :waiting_times_average => waiting_times_average,
      :waiting_times_percentage_from_worst => waiting_times_percentage_from_worst,
      :beds => @branch.beds.map do |bed|
        # Percentage relation between actual branch area beds' quantity and best area beds' quantity
        from_best = (bed.quantity.to_f/@common_info.best_beds[bed.area].to_f).round(2)
        {
          :area => bed.area,
          :quantity => bed.quantity,
          :from_best => from_best
        }
      end
    }
    render json: @response
  end

  private
end
