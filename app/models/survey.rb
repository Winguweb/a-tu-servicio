class Survey < ActiveRecord::Base
  belongs_to :branch
  default_scope { order(created_at: :asc) }
end
