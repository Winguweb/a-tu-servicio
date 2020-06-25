env = ENV['RAILS_ENV'] || Rails.env

# vuejs = APP_CONFIG[env]['vuejs'].freeze
VUEJS_CDN_URL = "https://cdn.jsdelivr.net/npm/vue@2.5.16/dist/vue.js"

# algolia = APP_CONFIG[env]['algolia'].freeze
ALGOLIA_APP_ID = 'ZRACX01RVB'
ALGOLIA_ADMIN_API_KEY = 'a84823f89a5f9ef1769f901882eff054'
ALGOLIA_SEARCH_API_KEY = 'd40fac79193db8e7fbe1f1ccd323d2e4'

# google = APP_CONFIG[env]['google'].freeze
# ANALYTICS_TRACKING_ID = google['analytics'].freeze
# GEOCODING_API_KEY = google['geocoding']['api_key']
# RECAPTCHA_SITEKEY = google['recaptcha']['sitekey']
# RECAPTCHA_SECRETKEY = google['recaptcha']['secretkey']
# RECAPTCHA_VERIFY_URL = google['recaptcha']['verifyUrl']
ANALYTICS_TRACKING_ID = ''
GEOCODING_API_KEY = ''
RECAPTCHA_SITEKEY = ''
RECAPTCHA_SECRETKEY = ''
RECAPTCHA_VERIFY_URL = ''

# ENV['GOOGLE_ANALYTICS']
# redis = APP_CONFIG[env]['redis'].freeze
REDIS_DB              = 0
REDIS_HOST            = 'localhost'
REDIS_PORT            = 6379
REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

MAPBOX_TOKEN = 'pk.eyJ1IjoianVhbmxhY3VldmEiLCJhIjoiY2s1MnBibDltMDA5NTNwbnRwOTM0cnhkdCJ9.17QsP4HUNocfKFxd_Cswuw'
