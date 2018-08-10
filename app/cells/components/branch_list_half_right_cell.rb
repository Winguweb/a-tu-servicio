class Components::BranchListHalfRightCell < Cell::ViewModel
  def branches
    model.map do |feature|
      {
        id: feature['id'],
        name: feature['name'].titlecase,
        provider_name: feature.provider.name,
        coordinates: feature['georeference'].coordinates.reverse,
      }
    end.to_json
  end
  private
end
