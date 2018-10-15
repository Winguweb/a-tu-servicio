env = ENV['RAILS_ENV'] || Rails.env

algolia = APP_CONFIG[env]['algolia'].freeze
ALGOLIA_APP_ID = algolia['application_id'].freeze
ALGOLIA_ADMIN_API_KEY = algolia['admin_api_key'].freeze
ALGOLIA_SEARCH_API_KEY = algolia['search_api_key'].freeze

google = APP_CONFIG[env]['google'].freeze
GEOCODING_API_KEY = google['geocoding']['api_key']

redis = APP_CONFIG[env]['redis'].freeze
REDIS_DB              = redis['db'].freeze
REDIS_HOST            = redis['host'].freeze
REDIS_PORT            = redis['port'].freeze
REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

MAPBOX_TOKEN    = APP_CONFIG[env]['mapbox']['token'].freeze
