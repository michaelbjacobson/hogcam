require 'rubygems'
require 'dotenv/load'
require 'sinatra/base'
require 'thin'
require 'rack/ssl-enforcer'
require 'logger'
require 'json'
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

  get '/' do
    erb :home
  end

  get '/login' do
    erb :login
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
