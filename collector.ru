$:.unshift File.expand_path(".", __FILE__)

require 'bundler'
Bundler.require

module PacketsAtRest
  ROLE = :collector
end

require './app/collector'
run PacketsAtRest::Collector
