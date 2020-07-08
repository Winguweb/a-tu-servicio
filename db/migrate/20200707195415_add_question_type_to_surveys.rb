class AddQuestionTypeToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :question_type, :string
    add_column :surveys, :question_subtype, :string
  end
end
