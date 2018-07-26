class Bed < ActiveRecord::Base
  belongs_to :branch
  default_scope { order(area: :asc) }
end
