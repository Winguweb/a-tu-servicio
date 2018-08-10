class Components::ReferenceMapCell < Cell::ViewModel

  private

  def features
    return [] if model.blank?
    Branch.includes(:provider).where.not(:georeference => nil).map do |feature|
      {
        id: feature['id'],
        name: feature['name'].titlecase,
        coordinates: feature['georeference'].coordinates.reverse,
        provider_name: feature.provider.name,
      }
    end.to_json
  end

  def map_defaults
    MAP.to_json
  end

end
