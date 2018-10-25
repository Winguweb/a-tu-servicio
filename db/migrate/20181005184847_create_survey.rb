class CreateSurvey < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.string :client_id, index: true
      t.integer :branch_id, index: true
      t.integer :step_id, index: true
      t.string :question_value
      t.integer :answer_id, index: true
      t.string :answer_value
      t.timestamps
    end
  end
end
