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
  @ead = xslt.transform(xml)
  @result = @ead.to_xml
  @filename = @ead.search('eadid').text

  if params[:disposition] =~ /^xml/
    content_type :xml
    if params[:disposition] =~ /file$/
      attachment @filename
    end
    @result
  else
    parser = Syntax::Convertors::HTML.for_syntax('xml')
    @output = parser.convert(@result,true)
    content_type :html
    haml :ead
  end
end
