require File.expand_path('../boot', __FILE__)

require 'rails/all'

APP_CONFIG = YAML.load_file(File.expand_path('../atsb.yml', __FILE__)).with_indifferent_access
MAP = YAML.load_file(File.expand_path('../map.yml', __FILE__))

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AtuservicioRails
  class Application < Rails::Application
    config.middleware.use Rack::Deflater
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not automatically include the all the helpers on the controllers
    config.action_controller.include_all_helpers = false

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.exceptions_app = self.routes

    config.cells.with_assets = %w(
      components/branch_detail_half_left_cell
      components/branch_detail_half_right_cell
      components/branch_detail_large_cell
      components/branch_info_popup_cell
      components/branch_full_detail_cell
      components/branch_list_half_right_cell
      components/branch_list_large_cell
      components/city_image_cell
      components/compare_branch_button_cell
      components/general_info_cell
      components/progress_circle_cell
      components/reference_map_cell
      components/site_footer_cell
      components/site_header_cell
      components/splash_cell
      components/story_slider_cell
      components/vote_modal_cell
      mobile_components/m_drawer_cell
      mobile_components/m_site_header_cell
      visualization_components/beds_visualization_cell
      visualization_components/in_hundreed_visualization_cell
      visualization_components/full_detail_bar_cell
      visualization_components/full_detail_bar_text_cell
      visualization_components/people_visualization_cell
      visualization_components/satisfaction_visualization_cell
      visualization_components/specialities_visualization_cell
      visualization_components/waiting_times_visualization_cell
    )

    api_mime_types = %W(
      application/vnd.api+json
      text/x-json
      application/json
    )
    Mime::Type.register 'application/vnd.api+json', :json, api_mime_types
  end
end
