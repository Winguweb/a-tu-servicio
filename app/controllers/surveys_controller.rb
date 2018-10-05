class SurveysController < ApplicationController
  def create
    @survey = Survey.find_or_initialize_by(survey_find_params)
    @survey.assign_attributes(survey_params)

    return render json: @survey if @survey.save
    return render json: errors.add_multiple_errors(@neighborhood.errors.messages), status: :failed_dependency
  end

  private

  def survey_params
    params.require(:vote).permit(
      :client_id,
      :branch_id,
      :step_id,
      :answer_id,
      :question_value,
      :answer_value,
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
