# config valid only for current version of Capistrano
lock "3.9.0"

# Change these
server 'vps.ajesler.nz', port: 2876, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:ajesler/in_use.git'
set :application,     'in_use'
set :user,            'deploy'
set :puma_threads,    [1, 4]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/vps-deploy.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
set :keep_releases, 1

## Linked Files & Directories (Default None):
set :linked_files, %w{db/production.sqlite3 .env}
set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :bundle_binstubs, nil

namespace :sqlite do
  desc 'Create a sqlite database file'
  task :create_db do
    on roles(:db) do
      execute "sqlite3 #{shared_path}/db/production.sqlite3 '.databases'"
    end
  end

  before 'deploy:symlink:shared', 'sqlite:create_db'
  before 'deploy:check:linked_files', 'sqlite:create_db'
end

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

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
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

  desc 'Create the .env file'
  task :create_dotenv do
    on roles(:app) do
      execute "touch #{shared_path}/.env"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  before 'deploy:check:linked_files', 'deploy:create_dotenv'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
