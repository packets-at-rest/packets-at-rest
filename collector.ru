$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require

module PacketsAtRest
  ROLE = :collector
end

# map just one file
map "/favicon.ico" do
    run Rack::File.new("public/favicon.ico")
end

require './app/collector'
run PacketsAtRest::Collector
