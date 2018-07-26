class Speciality < ActiveRecord::Base
  belongs_to :branch
  default_scope { order(name: :asc) }
end
