#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'nokogiri'
require 'syntax/convertors/html'

get '/' do
  redirect '/ead'
end

get '/ead' do
  haml :form
end

post '/ead' do
  xml = Nokogiri::XML(params[:ead_file][:tempfile].read)
  xslt = Nokogiri::XSLT(File.read('public/nwda_ead.xsl'))
  @ead = xslt.transform(xml).to_xml

  @filename = params[:ead_file][:filename]
  if params[:disposition] =~ /^xml/
    content_type :xml
    if params[:disposition] =~ /file$/
      attachment @filename
    end
    @ead
  else
    parser = Syntax::Convertors::HTML.for_syntax('xml')
    @output = parser.convert(@ead,true)
    content_type :html
    haml :ead
  end
end
