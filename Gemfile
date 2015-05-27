source 'https://rubygems.org'
gem 'rack', '~> 1.6.0'
gem 'json', '~> 1.8.2'
gem 'chronic', '~> 0.10.2'
gem 'sinatra', '~> 1.4.5'
gem 'sys-uptime', '~> 0.6.2'
gem 'rest-client', '~> 1.8.0'
gem 'sinatra-initializers', '~> 0.1.4'
gem "sinatra-param", require: "sinatra/param"
gem 'alpaca'

group :thin do
  gem 'thin'
end

group :debug do
  gem 'pry'
end

group :coverage do
  gem 'simplecov', :require => false
end

group :test do
    gem 'bump', '~> 0.3', require: nil
    gem 'rake', require: nil
    gem 'rack-test', require: nil
    gem "codeclimate-test-reporter", require: nil
    gem "minitest-reporters", require: nil
end
