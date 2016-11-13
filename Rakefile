require 'rake/tasklib'
require 'rake/sprocketstask'
require './app'

namespace :assets do
  desc 'Precompile assets'
  task :precompile => :clean do
    environment = Application.sprockets
    manifest = Sprockets::Manifest.new(environment.index, File.join(Application.assets_public_path, 'manifest.json'))
    manifest.compile(Application.assets_precompile)
  end

  desc 'Clean assets'
  task :clean do
    FileUtils.rm_rf(Application.assets_prefix)
  end
end
