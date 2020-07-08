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
      :slug,
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

  # TODO new workers
  def quality
    redis.get("quality/branch/#{id}").to_f.round.to_i
  end

  def waiting_times
    redis.get("waiting_times/branch/#{id}").to_f.round.to_i
  end

  def satisfaction
    redis.get("satisfaction/branch/#{id}").to_f.round.to_i
  end

  def humanization
    redis.get("humanization/branch/#{id}").to_f.round.to_i
  end

  def risk
    redis.get("risk/branch/#{id}").to_f.round.to_i
  end

  def effectiveness
    redis.get("effectiveness/branch/#{id}").to_f.round.to_i
  end
  # TODO new workers

  private

  def redis
    $redis
  end

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
