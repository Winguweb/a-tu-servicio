# env = ENV['RAILS_ENV'] || Rails.env

# vuejs = APP_CONFIG[env]['vuejs'].freeze
# VUEJS_CDN_URL = vuejs['cdn_url']

# algolia = APP_CONFIG[env]['algolia'].freeze
# ALGOLIA_APP_ID = algolia['application_id'].freeze
# ALGOLIA_ADMIN_API_KEY = algolia['admin_api_key'].freeze
# ALGOLIA_SEARCH_API_KEY = algolia['search_api_key'].freeze

# google = APP_CONFIG[env]['google'].freeze
# ANALYTICS_TRACKING_ID = google['analytics'].freeze
# GEOCODING_API_KEY = google['geocoding']['api_key']
# USE_RECAPTCHA = google['recaptcha']['use']
# RECAPTCHA_SITEKEY = google['recaptcha']['sitekey']
# RECAPTCHA_SECRETKEY = google['recaptcha']['secretkey']
# RECAPTCHA_VERIFY_URL = google['recaptcha']['verifyUrl']

# redis = APP_CONFIG[env]['redis'].freeze
# REDIS_DB              = redis['db'].freeze
# REDIS_HOST            = redis['host'].freeze
# REDIS_PORT            = redis['port'].freeze
# REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

# MAPBOX_TOKEN    = APP_CONFIG[env]['mapbox']['token'].freeze


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
USE_RECAPTCHA = ENV['USE_RECAPTCHA'] 

# ENV['GOOGLE_ANALYTICS']
# redis = APP_CONFIG[env]['redis'].freeze
REDIS_DB              = ENV['REDIS_DB']
REDIS_HOST            = ENV['REDIS_HOST']
REDIS_PORT            = ENV['REDIS_PORT']
REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

MAPBOX_TOKEN    = ENV['MAPBOX_TOKEN']
# env = ENV['RAILS_ENV'] || Rails.env
# # vuejs = APP_CONFIG[env]['vuejs'].freeze
# VUEJS_CDN_URL = "https://cdn.jsdelivr.net/npm/vue@2.5.16/dist/vue.js"

# # algolia = APP_CONFIG[env]['algolia'].freeze
# ALGOLIA_APP_ID = 'ZRACX01RVB'
# ALGOLIA_ADMIN_API_KEY = 'a84823f89a5f9ef1769f901882eff054'
# ALGOLIA_SEARCH_API_KEY = 'd40fac79193db8e7fbe1f1ccd323d2e4'

# # google = APP_CONFIG[env]['google'].freeze
# # ANALYTICS_TRACKING_ID = google['analytics'].freeze
# # GEOCODING_API_KEY = google['geocoding']['api_key']
# # RECAPTCHA_SITEKEY = google['recaptcha']['sitekey']
# # RECAPTCHA_SECRETKEY = google['recaptcha']['secretkey']
# # RECAPTCHA_VERIFY_URL = google['recaptcha']['verifyUrl']
# ANALYTICS_TRACKING_ID = ''
# GEOCODING_API_KEY = ''
# RECAPTCHA_SITEKEY = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
# USE_RECAPTCHA = false
# RECAPTCHA_SECRETKEY = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'
# RECAPTCHA_VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify'
# # ENV['GOOGLE_ANALYTICS']
# # redis = APP_CONFIG[env]['redis'].freeze
# REDIS_DB              = 0
# REDIS_HOST            = 'localhost'
# REDIS_PORT            = 6379
# REDIS_URL             = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze

# MAPBOX_TOKEN = 'pk.eyJ1IjoianVhbmxhY3VldmEiLCJhIjoiY2s1MnBibDltMDA5NTNwbnRwOTM0cnhkdCJ9.17QsP4HUNocfKFxd_Cswuw'