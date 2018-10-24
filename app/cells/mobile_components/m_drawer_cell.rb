class MobileComponents::MDrawerCell < Cell::ViewModel

  def current_user
    UserSession.find
  end

  private

end
