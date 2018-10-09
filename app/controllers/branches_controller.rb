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
    @branch = Branch.includes(:provider, :specialities).find_by(id: params[:id])
    @provider = @branch.provider
    @waiting_times = @provider.waiting_times
    @satisfactions = @provider.satisfactions
    @specialities = @branch.specialities
    @base_response = BaseResponseService.call(@branch)
    @flag_response = FlagResponseService.call(@branch)
    @satisfaction_response = SatisfactionResponseService.call(@branch)
    @speciality_response = SpecialityResponseService.call(@branch)
    @waiting_time_response = WaitingTimeResponseService.call(@branch)

    # TODO: WIP
    # ==========================================================================
    @surveys = Survey.where(branch_id: @branch.id)
    user_waiting_times = {}
    @surveys.where(step_id: 6).each do |waiting_time|
      speciality = @surveys.where(step_id: 2, client_id: waiting_time.client_id).first.answer_value
      user_waiting_times[speciality] = 0 if user_waiting_times[speciality].blank?
      user_waiting_times[speciality] += waiting_time.answer_value.to_i
    end
    # ==========================================================================

    @response = {
      **@base_response.response,
      **@flag_response.response,
      **@satisfaction_response.response,
      **@speciality_response.response,
      **@waiting_time_response.response,
    }
    render json: @response
  end

  private
end
