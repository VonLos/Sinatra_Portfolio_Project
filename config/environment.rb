ENV['SINATRA_ENV'] ||= "development"
require 'open-uri'
require 'net/http'
require 'json'
require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])
Dotenv.load if ENV['SINATRA_ENV'] == "development"


set :database_file, "./database.yml"
require './app/controllers/application_controller'
require_all 'app'