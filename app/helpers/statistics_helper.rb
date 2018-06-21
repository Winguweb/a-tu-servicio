# coding: utf-8
# Helper for values we want to show in the home page
#
module StatisticsHelper
  def as_people(value, total_people = 10)
    return (10 * value).round(0).to_i
  end

  def as_percentage(value)
    return (100 * value).round(0).to_i
  end
end
