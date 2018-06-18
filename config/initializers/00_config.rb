env = ENV['RAILS_ENV'] || Rails.env

google = APP_CONFIG[env]['google'].freeze
GEOCODING_API_KEY = google['geocoding']['api_key']

redis = APP_CONFIG[env]['redis'].freeze
REDIS_DB              = redis['db'].freeze
REDIS_HOST            = redis['host'].freeze
REDIS_PORT            = redis['port'].freeze
REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze
