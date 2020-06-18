threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart

# Fix for beanstalk
# bind "unix:///var/run/puma/my_app.sock"
# pidfile "/var/run/puma/my_app.sock"