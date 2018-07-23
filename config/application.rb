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

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.exceptions_app = self.routes

    config.cells.with_assets = %w(
      visualization_components/specialities_visualization_cell
      visualization_components/in_hundreed_visualization_cell
      visualization_components/people_visualization_cell
      components/compare_provider_button_cell
      components/provider_detail_half_right_cell
      components/provider_detail_half_left_cell
      components/provider_detail_large_cell
      components/provider_list_half_right_cell
      components/provider_list_large_cell
      components/reference_map_cell
      components/site_header_cell
      components/story_slider_cell
    )
  end
end
