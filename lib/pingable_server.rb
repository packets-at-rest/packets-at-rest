# Stdlib
require 'sys/uptime'

# Gems
require 'json'
require 'sinatra/base'
require 'sinatra/param'
require 'sinatra-initializers'


module PacketsAtRest
  class PingableServer < Sinatra::Base
    register Sinatra::Initializers

    set :logging, true
    set :dump_error, true
    set :raise_errors, true
    set :show_exceptions, true

    get '/ping' do
      content_type :json
      begin
        return {
          "version" => PacketsAtRest::VERSION,
          "api_version" => PacketsAtRest::API_VERSION,
          "uptime" => Sys::Uptime.uptime,
          "date" => Time.now.utc,
          "role" => PacketsAtRest::ROLE.to_s
        }.to_json
      rescue
        return internalerror 'there was a problem getting heartbeat'
      end
    end

    get '/*' do
      return badrequest 'this request is not supported'
    end

    def error_message msg
      {
        "error" => msg
      }.to_json
    end

    def notfound msg
      content_type :json
      [404, error_message(msg)]
    end

    def badrequest msg
      content_type :json
      [400, error_message(msg)]
    end

    def unauthorized msg
      content_type :json
      [401, error_message(msg)]
    end

    def forbidden msg
      content_type :json
      [403, error_message(msg)]
    end

    def internalerror msg
      content_type :json
      [500, error_message(msg)]
    end

  end
end
