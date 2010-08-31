require 'rubygems'
require 'sinatra'

set :environment, :production
disable :run

require 'at_ead'
run Sinatra::Application
