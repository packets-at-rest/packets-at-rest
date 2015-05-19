$LOAD_PATH.unshift File.expand_path('.', __FILE__)
require "./lib/version"

require 'bundler'
require 'rake/testtask'
require 'bump/tasks'
require 'fileutils'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc 'Set Role Node'
task :role_node do
    FileUtils.ln_s 'node.ru', 'config.ru', :force => true
end

desc 'Set Role Collector'
task :role_collector do
    FileUtils.ln_s 'collector.ru', 'config.ru', :force => true
end

desc 'release TAG to github'
task :release do
    `git tag -a #{PacketsAtRest::VERSION} -m 'release tag #{PacketsAtRest::VERSION}'`
    `git push origin master`
end
