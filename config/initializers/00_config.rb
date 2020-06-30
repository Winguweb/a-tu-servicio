env = ENV['RAILS_ENV'] || Rails.env

# vuejs = APP_CONFIG[env]['vuejs'].freeze
VUEJS_CDN_URL = ENV['VUE_CDN']

# algolia = APP_CONFIG[env]['algolia'].freeze
ALGOLIA_APP_ID = ENV['ALGOLIA_APP_KEY']
ALGOLIA_ADMIN_API_KEY = ENV['ALGOLIA_ADMIN_KEY']
ALGOLIA_SEARCH_API_KEY = ENV['ALGOLIA_SEARCH_KEY']

# google = APP_CONFIG[env]['google'].freeze

# ANALYTICS_TRACKING_ID = google['analytics'].freeze
# GEOCODING_API_KEY = google['geocoding']['api_key']
# RECAPTCHA_SITEKEY = google['recaptcha']['sitekey']
# RECAPTCHA_SECRETKEY = google['recaptcha']['secretkey']
# RECAPTCHA_VERIFY_URL = google['recaptcha']['verifyUrl']
ANALYTICS_TRACKING_ID = ENV['GOOGLE_ANALYTICS']
GEOCODING_API_KEY = ENV['GOOGLE_GEOCODING']
RECAPTCHA_SITEKEY = ENV['GOOGLE_SITEKEY']
RECAPTCHA_SECRETKEY = ENV['GOOGLE_CAPTCHA_SECRETKEY']
RECAPTCHA_VERIFY_URL = ENV['GOOGLE_RECAPTCHA_VERIFY_URL']

# ENV['GOOGLE_ANALYTICS']
# redis = APP_CONFIG[env]['redis'].freeze
REDIS_DB              = ENV['REDIS_DB']
REDIS_HOST            = ENV['REDIS_HOST']
REDIS_PORT            = ENV['REDIS_PORT']
REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

MAPBOX_TOKEN    = ENV['MAPBOX_TOKEN']