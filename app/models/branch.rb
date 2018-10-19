class Branch < ActiveRecord::Base
  include AlgoliaSearch

  acts_as_taggable_on :levels, :categories

  has_many :specialities, dependent: :delete_all
  has_many :beds, dependent: :delete_all
  belongs_to :state, optional: true
  belongs_to :provider

  default_scope ->{ order(name: :asc) }

  algoliasearch per_environment: true, if: :should_index? do
    attribute :address,
      :name,
      :town,
      :provider_name,
      :show,
      :specialities_names,
      :subnet_name

    searchableAttributes %w[
      unordered(name)
      unordered(provider_name)
      specialities_names
      unordered(address)
    ]

    attributesForFaceting %i[ specialities_names ]

    geoloc :lat, :lng
  end

  def latlng
    return [ nil, nil ] unless georeference

    georeference.coordinates.reverse
  end

  private

  def lat
    latlng[0]
  end

  def lng
    latlng[1]
  end

  def should_index?
    provider.show?
  end

  def provider_name
    provider.name
  end

  def show
    provider.show
  end

  def specialities_names
    specialities.map(&:name)
  end

  def subnet_name
    provider.subnet
  end
end
