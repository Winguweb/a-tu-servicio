require 'survey_data'

# VOTE_DATA = YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml")).with_indifferent_access

$survey_data = SurveyData.new(steps: YAML.load_file(File.join(Rails.root, "app", "cells", "components", "vote_modal", "vote_data.yml")).with_indifferent_access['steps'])
