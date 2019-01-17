source 'https://rubygems.org'
ruby '~> 2.4.0'

gem 'rails', '~> 5.2.0'
gem 'activerecord-postgis-adapter'
gem 'pg'
gem 'algoliasearch-rails'
gem 'acts-as-taggable-on'
gem 'authlogic'
gem 'slim'
gem 'uglifier'
gem 'sass-rails'
gem 'neat' # A lightweight and flexible Sass grid
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'puma'
gem 'redis-namespace'
gem 'rollbar'
gem 'cells-rails'
gem 'cells-slim', git: "git@github.com:trailblazer/cells-slim", branch: :master
gem 'sidekiq'
gem 'typhoeus'

gem 'rubyzip', '>= 1.2.1'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'

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
end

group :production do
  gem 'rails_12factor'
end

group :development do
  gem 'capistrano',             require: false
  gem 'capistrano-bundler',     require: false
  gem 'capistrano3-puma',       require: false
  gem 'capistrano-rails',       require: false
  gem 'capistrano-maintenance', require: false
end
