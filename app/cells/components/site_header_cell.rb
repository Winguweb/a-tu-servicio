class Components::SiteHeaderCell < Cell::ViewModel

  def current_user
    UserSession.find
  end
  private

end
