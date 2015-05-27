$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require
use Rack::Alpaca

module PacketsAtRest
  ROLE = :node
end

require './app/node'
run PacketsAtRest::Node
