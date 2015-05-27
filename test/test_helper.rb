# test_helper.rb
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
require_relative 'support/awesomereporter'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

# spec_helper.rb
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
      add_filter "/test/"
  end
end

require 'rack/test'

module PacketsAtRest
  ROLE = :unit_test
end

reporter_options = { color: true, slow_count: 5, slow_threshold: 0.02  }
Minitest::Reporters.use! [Minitest::Reporters::AwesomeReporter.new(reporter_options)]
