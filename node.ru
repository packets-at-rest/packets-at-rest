$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require
require './node/node'
run PacketsAtRest::Node
