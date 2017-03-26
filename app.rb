$LOAD_PATH << File.expand_path('../', __FILE__)

require 'rubygems'
require 'bundler'
require 'autoprefixer-rails'

Bundler.require

class Application < Sinatra::Base
  register Sinatra::Flash
  register Sinatra::Reloader

  environment = Sprockets::Environment.new
  AutoprefixerRails.install(environment)

  set :sprockets, environment
  set :assets_prefix, '/assets'
  set :assets_precompile, %w(application.js application.scss *.png *.jpg *.svg)
  set :assets_public_path, -> { File.join(public_folder, 'assets') }

  sprockets.append_path 'assets/stylesheets'
  sprockets.append_path 'assets/javascripts'
  sprockets.append_path 'assets/images'

  sprockets.css_compressor = :scss

  configure :development do
    sprockets.cache = Sprockets::Cache::FileStore.new('./tmp')

    get '/assets/*' do |asset|
      env['PATH_INFO'].sub!(%r{^/assets}, '')
      settings.sprockets.call(env)
    end
  end

  configure do
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = assets_prefix
      config.public_path = public_folder
      config.digest = true
      config.debug = development?

      if production?
        config.manifest = Sprockets::Manifest.new(sprockets, File.join('tmp', 'manifest.json'))
      end
    end
  end

  helpers do
    include Sprockets::Helpers

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def root_url
      "http://#{headers['SERVER_NAME'] || 'localhost:3000'}"
    end

    def from_root_url(text)
      root_url + '/' + text.to_s
    end
  end

  get '/' do
    haml :index
  end
end
