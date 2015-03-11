require 'bundler'
Bundler.require
require_relative 'collector'
run PacketsAtRest::Collector
