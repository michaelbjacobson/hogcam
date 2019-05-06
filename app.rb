require 'rubygems'
require 'dotenv/load'
require 'sinatra/base'
require 'thin'
require 'rack/ssl-enforcer'
require 'logger'
require 'json'
require_relative './lib/aws'
require_relative './lib/raspberry_pi'
require_relative './lib/weather'

# App
class App < Sinatra::Base
  configure do
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(128) }
    use Rack::SslEnforcer if ENV['RACK_ENV'] == 'production'
    use Rack::Session::Cookie,
        key: '_rack_session',
        path: '/',
        expire_after: 2_592_000,
        secret: settings.session_secret
  end

  helpers do
    def weather
      Weather.conditions
    end

    def time
      Time.now.to_i
    end

    def authenticated?
      session[:authenticated]
    end
  end

  before '/' do
    redirect '/login' unless authenticated?
  end

  before '/raspi/*' do
    redirect '/' unless request.xhr?
  end

  get '/' do
    erb :home
  end

  get '/login' do
    erb :login
  end

  get '/raspi/status' do
    RaspberryPi.status.to_json
  end

  get '/raspi/timelapse_active' do
    RaspberryPi.timelapse_active?.to_s
  end

  get '/raspi/preview' do
    AWS.preview_url
  end

  post '/raspi/reboot' do
    RaspberryPi.reboot
  end

  post '/raspi/toggle_timelapse' do
    RaspberryPi.timelapse_active? ? RaspberryPi.stop_timelapse : RaspberryPi.start_timelapse
  end

  post '/raspi/update_preview' do
    RaspberryPi.update_preview unless RaspberryPi.timelapse_active?
  end

  post '/authenticate' do
    session[:authenticated] = true if params['password'] == ENV['PASSWORD']
    redirect '/'
  end

  post '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

  not_found do
    redirect '/'
  end
end
