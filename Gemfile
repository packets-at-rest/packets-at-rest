source 'https://rubygems.org'
gem 'rake', '~> 10.4.2' , :require => nil
gem 'rack', '~> 1.6.0'
gem 'json', '~> 1.8.2'
gem 'chronic', '~> 0.10.2'
gem 'sinatra', '~> 1.4.5'
gem 'sys-uptime', '~> 0.6.2'
gem 'rest-client', '~> 1.8.0'
gem 'sinatra-initializers', '~> 0.1.4'
gem "sinatra-param", require: "sinatra/param"
gem 'sinatra-strong-params', :require => 'sinatra/strong-params'
gem 'alpaca'

gem 'warden'

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
    gem "minitest", '~> 5.6', require: nil
    gem 'bump', '~> 0.3', require: nil
    gem 'rack-test', require: nil
    gem "codeclimate-test-reporter", require: nil
    gem "minitest-reporters", require: nil
end

# Install gems from each plugin
Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
