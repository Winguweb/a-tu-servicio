class Components::BranchListLargeCell < Cell::ViewModel
  def branches
    model.to_json
  end
  private
end
