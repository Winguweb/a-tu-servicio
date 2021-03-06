# config valid only for current version of Capistrano
lock "3.11.0"

set :application, "atsb"
set :repo_url,    "git@github.com:Winguweb/a-tu-servicio.git"
set :user,        "deploy"

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/data/#{fetch(:application)}"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

set :puma_threads,    [4, 16]
set :puma_workers,    4
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma.error.log"
set :puma_error_log,  "#{shared_path}/log/puma.access.log"
set :puma_preload_app, false
set :puma_worker_timeout, nil
set :puma_init_active_record, false

set :assets_roles, [ :app ]
set :keep_assets, 4

set :linked_files, %w{config/atsb.yml config/secrets.yml config/puma.rb config/database.yml config/sidekiq.yml}
set :linked_dirs,  %w{bundle lib/tasks/log log public/system tmp/cache tmp/pids tmp/sockets}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'sidekiq' | xargs kill -USR1")
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :service, :sidekiq, :restart
    end
  end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Upload to shared/config'
  task :upload_config_files do
    on roles (:app) do
      upload! "config/deploy/files/#{fetch(:stage)}/atsb.yml", "#{shared_path}/config/atsb.yml"
      upload! "config/deploy/files/#{fetch(:stage)}/database.yml", "#{shared_path}/config/database.yml"
      upload! "config/deploy/files/#{fetch(:stage)}/secrets.yml",  "#{shared_path}/config/secrets.yml"
      upload! "config/deploy/files/#{fetch(:stage)}/sidekiq.yml",  "#{shared_path}/config/sidekiq.yml"
      invoke 'puma:config'
    end
  end

  before :starting,     :check_revision
  after  :starting,     'sidekiq:quiet'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
  after  :reverted,     'sidekiq:restart'
  after  :published,    'sidekiq:restart'
end
