#!/usr/bin/env ruby
begin
  require 'rubygems'
  require 'bundler'
  Bundler.setup(:default)
rescue ::Exception => e
end

# Executable with absolute path to lib for hacking and development
# require File.join(File.dirname(__FILE__), '..', 'lib', 'filer', 'cli')

require 'fileutils'
require 'optparse'
require 'logger'

require_relative '../config/config'
require_relative '../ext/util'
require_relative '../lib/filer/cli'
require_relative '../lib/filer/filer'

PacketsAtRest::Filer::CLI.invoke
