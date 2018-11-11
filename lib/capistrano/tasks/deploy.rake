namespace :deploy do
  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  namespace :nginx do
    %w(start stop restart).each do |command|
      desc "#{command} nginx."
      task command do
        on roles(:app) do
          execute "sudo service nginx #{command}"
        end
      end
    end

    desc "Symlinks config files for Nginx."
    task :enable_site do
      on roles(:app) do
        execute "cd #{current_path} && sudo cp config/nginx/sites-available/evinatherton.com /etc/nginx/sites-enabled/#{fetch(:application)}"
      end
    end
  end

end
