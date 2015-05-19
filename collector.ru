$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require
require './collector/collector'
run PacketsAtRest::Collector
