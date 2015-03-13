require 'bundler'
Bundler.require
require_relative 'collector/collector'
run PacketsAtRest::Collector
