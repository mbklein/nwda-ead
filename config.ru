require 'rubygems'
require 'sinatra'

set :environment, :development
disable :run

require 'nwda_ead'
run Sinatra::Application
