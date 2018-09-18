class Branch < ActiveRecord::Base
  searchkick word_start: [:name, :provider_name, :address, :specialities], language: "spanish" , suggest: [:name, :provider_name, :specialities]
  has_many :specialities, dependent: :delete_all
  has_many :beds, dependent: :delete_all
  acts_as_taggable_on :levels, :categories
  belongs_to :state, optional: true
  belongs_to :provider
  default_scope { order(name: :asc) }

  def search_data
    {
      address: address,
      georeference: georeference,
      name: name,
      town: town,
      provider_name: provider.name,
      show: provider.show,
      specialities: specialities.map(&:name),
      subnet_name: provider.subnet
    }
  end

  def should_index?
    self.provider.show
  end
end

#If indices are blocked
#**********************
#Try running Job.search_index.clean_indices in the console first and see if that helps.
#If you still get that error, you could also try adding the following to your searchkick config in the Job model and reindexing (although it shouldn't really be necessary):
#searchkick settings: {blocks: {read_only: false}}
#If you are still getting the error, then the final thing you could try would be to delete the existing index first by running Job.search_index.delete and then reindexing to create a new index.

