set :stage, :staging
set :branch, "covid-19"

server '34.224.95.156', user: 'deploy', roles: %w{ app }

set :rails_env, :production
set :puma_env, :production
set :puma_config_file, "#{shared_path}/config/puma.rb"
set :puma_conf, "#{shared_path}/config/puma.rb"
