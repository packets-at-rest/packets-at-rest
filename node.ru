$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require
use Rack::Alpaca

module PacketsAtRest
  ROLE = :node
end

# map just one file
map "/favicon.ico" do
    run Rack::File.new("public/favicon.ico")
end

require './app/node'
run PacketsAtRest::Node
