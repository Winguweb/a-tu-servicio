class Branch < ActiveRecord::Base
  acts_as_taggable_on :levels, :categories
  belongs_to :state
  belongs_to :provider
end
