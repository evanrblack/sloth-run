# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'sloth-run'
set :repo_url, 'git@github.com:evanrblack/sloth-run.git'
set :deploy_to, "~/apps/#{fetch :application}"

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

append :linked_dirs, 'tmp', 'log', 'config'

namespace :deploy do
  desc 'Make directories for PIDs and Sockets'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/pids -p"
      execute "mkdir #{shared_path}/tmp/sockets -p"
    end
  end

  before :starting, :make_dirs
  after :finishing, 'thin:restart'
end

