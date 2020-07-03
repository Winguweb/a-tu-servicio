class Components::ReferenceMapCell < Cell::ViewModel

  private

  def branches
    return [] if model.blank?

    model.map do |branch|
      {
        id: branch.id.to_s,
        name: branch.name,
        coordinates: branch.latlng,
        provider_name: branch.provider.name,
        featured: branch.provider.featured,
        quality: branch.quality,
        waiting_times: branch.waiting_times,
        satisfaction: branch.satisfaction,
        humanization: branch.humanization,
        slug: branch.slug
      }
    end.to_json
  end

  def map_defaults
    MAP.to_json
  end

end
