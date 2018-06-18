class Components::ReferenceMapCell < Cell::ViewModel

  private

  def features
    return [] if model.blank?
    model.map do |feature|
      {
        name: feature.name,
        coordinates: feature.georeference.coordinates.reverse,
      }
    end.to_json
  end

  def map_defaults
    MAP.to_json
  end

end
