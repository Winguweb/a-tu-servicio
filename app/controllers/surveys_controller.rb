class SurveysController < ApplicationController
  def create
    # return error_message unless recaptcha_was_verified? || recaptcha_verified?
    multi_response = params[:vote][:multi_response]

    @survey = get_existing_or_new_survey(multi_response)
    @survey.assign_attributes(survey_params)

    return render json: @survey if @survey.save
    return render json: errors.add_multiple_errors(@neighborhood.errors.messages), status: :failed_dependency
  end

  private

  def get_existing_or_new_survey(multi_response)
    return Survey.find_or_initialize_by(survey_find_params) unless multi_response
    return Survey.new if multi_response
  end

  def error_message
    render json: {status: 429, message: 'recaptcha failed'}, status: 429
  end

  def recaptcha_was_verified?
    session[:recaptcha_success].present?
  end

  def recaptcha_verified?
    request = Typhoeus::Request.new(
      RECAPTCHA_VERIFY_URL,
      method: :post,
      params: {
        secret: RECAPTCHA_SECRETKEY,
        response: params[:token]
      }
    )

    request.run
    
    puts params
    response = request.response
    puts 'Response!'
    # puts JSON.parse(response)
    puts '---'
    puts JSON.parse(response.options[:response_body])
    success = JSON.parse(response.options[:response_body])['success']
    session[:recaptcha_success] = success
  end

  def survey_params
    params.require(:vote).permit(
      :client_id,
      :branch_id,
      :step_id,
      :answer_id,
      :question_value,
      :question_subtype,
      answer_data: [:label, :value],
    )
  end

  def survey_find_params
    params.require(:vote).permit(
      :client_id,
      :branch_id,
      :step_id,
    )
  end
end
