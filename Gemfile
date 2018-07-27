source 'https://rubygems.org'
ruby '2.4.1'

gem 'rails', '~> 5.2.0'
gem 'activerecord-postgis-adapter'
gem 'pg'
gem 'searchkick'
gem 'acts-as-taggable-on'
gem 'slim'
gem 'uglifier'
gem 'sass-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'neat' # A lightweight and flexible Sass grid
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'puma'
gem 'rollbar'
gem 'cells-rails'
gem 'cells-slim', git: "git@github.com:trailblazer/cells-slim", branch: :master

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'pry'
  gem 'byebug'
  gem 'query_diet'
  gem 'bullet'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'active_record_query_trace'
  gem 'derailed'
  gem 'typhoeus'
  gem 'redis-rails'
  gem 'redis-namespace'
  gem 'sidekiq'
end

group :production do
  gem 'rails_12factor'
end
