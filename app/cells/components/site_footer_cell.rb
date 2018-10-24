class Components::SiteFooterCell < Cell::ViewModel

  private

  def active_links?
    (model && model[:active_links]) || false
  end

end
