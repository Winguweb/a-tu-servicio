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
      specialities: specialities.map(&:name),
      subnet_name: provider.subnet
    }
  end

end
