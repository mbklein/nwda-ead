#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'nokogiri'
require 'syntax/convertors/html'

get '/' do
  haml %{
%html
  %head
  %body
    %form{:method => 'POST', :enctype => 'multipart/form-data'}
      %input{:type => 'file', :name => 'ead_file'}
      %br
      %label{:for => 'disposition'} Receive output as:
      %input{:type => 'radio', :name => 'disposition', :value => 'xml'} XML (in-browser)
      %input{:type => 'radio', :name => 'disposition', :value => 'xmlfile'} XML (download)
      %input{:type => 'radio', :name => 'disposition', :value => 'html'} HTML (display)
      %br
      %input{:type => 'submit', :value => 'Submit'}
}
end

post '/' do
  xml = Nokogiri::XML(params[:ead_file][:tempfile].read)
  xslt = Nokogiri::XSLT(File.read('at_ead.xsl'))
  result = xslt.transform(xml).to_s
  
  if params[:disposition] =~ /^xml/
    content_type :xml
    if params[:disposition] =~ /file$/
      attachment params[:ead_file][:filename]
    end
    result
  else
    parser = Syntax::Convertors::HTML.for_syntax('xml')
    output = parser.convert(result,true)
    content_type :html
    %{
<html>
  <head>
    <title>#{params[:ead_file][:filename]}</title>
    <link rel="stylesheet" type="text/css" href="xml.css"/>
  </head>
  <body>
  #{output}
  </body>
</html>
    }
  end
end
