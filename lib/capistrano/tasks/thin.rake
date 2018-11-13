namespace :thin do
  commands = [:start, :stop, :restart]

  commands.each do |command|
    desc "thin #{command}"
    task command do
      on roles(:app), in: :sequence, wait: 5 do
        within current_path do
          config_file = "config/thin.yml"
          execute "cd #{current_path} && sudo RACK_ENV=production bundle exec thin #{command} -C #{config_file}"
        end
      end
    end
  end
end
