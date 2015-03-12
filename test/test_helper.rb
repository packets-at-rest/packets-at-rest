# test_helper.rb
ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

require_relative '../collector.rb'
require_relative 'config.rb'
