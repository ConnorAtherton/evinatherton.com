# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'evinatherton.com'
set :repo_url, 'git@github.com:ConnorAtherton/evinatherton.com.git'
set :branch, :master

set :user, 'Connor'
set :port, 22

set :deploy_to, "/var/www/#{fetch(:application)}"
set :deploy_via, :rsync_with_remote_cache
set :keep_releases, 3
set :log_level, :debug

namespace :deploy do
  after :deploy, 'thin:restart'
end
