require 'sinatra/base'
require 'json'

module PacketsAtRest
  class PingableServer < Sinatra::Base
    get '/ping' do
      content_type :json
      begin
        return {
          "uptime" => Sys::Uptime.uptime,
          "date" => Time.now
        }.to_json
      rescue
        return internalerror 'there was a problem getting uptime and date'
      end
    end

    get '/*' do
      return badrequest 'this request is not supported'
    end

    def error_message msg
      {
        "type" => "error",
        "message" => msg
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
