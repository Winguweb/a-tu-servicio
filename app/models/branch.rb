class Branch < ActiveRecord::Base
  has_many :specialities, dependent: :delete_all
  acts_as_taggable_on :levels, :categories
  belongs_to :state, optional: true
  belongs_to :provider
  default_scope { order(name: :asc) }

end
