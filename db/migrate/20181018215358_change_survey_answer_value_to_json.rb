class ChangeSurveyAnswerValueToJson < ActiveRecord::Migration[5.2]
  def self.up

      rename_column :surveys, :answer_value, :answer_data

      Survey.find_each do |survey|
        survey.answer_data = {
          label: survey.answer_data,
          value: survey.answer_data
        }.to_json.to_s
        survey.save!
      end

      change_column :surveys, :answer_data, :json, using: 'answer_data::JSON'
  end

  def self.down
      change_column :surveys, :answer_data, :string
      rename_column :surveys, :answer_data, :answer_value
  end

end
