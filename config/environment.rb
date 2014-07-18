require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/content_for'
require 'omniauth'
require 'omniauth-facebook'

require 'pry'


APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

# Sinatra configuration
configure do
  set :root, APP_ROOT.to_path
  set :server, :puma

  enable :sessions
  set :session_secret, ENV['SESSION_KEY'] || 'lighthouselabssecret'

  set :views, File.join(Sinatra::Application.root, "app", "views")

  # use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :identity, fields: [:email, :name], model: User, on_failed_registration: lambda { |env|
      status, headers, body = call env.merge("PATH_INFO" => '/register')
    }
    provider :facebook, '666460076756482','96ba18c909df0c6cae43245e43ec5beb'
    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end
end

# Set up the database and models
require APP_ROOT.join('config', 'database')

# Load the routes / actions
require APP_ROOT.join('app', 'actions')