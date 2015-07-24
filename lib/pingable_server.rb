# Stdlib
require 'sys/uptime'

# Gems
require 'json'
require 'warden'

require 'sinatra/base'
require 'sinatra/param'
require 'sinatra-initializers'
require 'sinatra/strong-params'

# Require Local
require_relative '../lib/version'
require_relative '../config/config'
require_relative '../ext/util'

module PacketsAtRest
  class PingableServer < Sinatra::Base
    register Sinatra::Initializers
    register Sinatra::StrongParams

    set :logging, true
    set :dump_error, true
    set :raise_errors, true
    set :show_exceptions, true

    PacketsAtRest::Plugin.all.each do |plugin|
        b = "PacketsAtRest::#{plugin.id.to_s.camelcase}::Plugin"
        use Object.const_get19(b)
    end

    # Configure Warden
    use Warden::Manager do |config|
        config.scope_defaults :default,
        # Set your authorization strategy
        strategies: [:admin_access_token, :node_access_token],
        # Route to redirect to when warden.authenticate! returns a false answer.
        action: '/unauthenticated'
        config.failure_app = self
    end

    Warden::Manager.before_failure do |env,opts|
        env['REQUEST_METHOD'] = 'POST'
    end

    get '/routes', allows: [:api_key] do
        env['warden'].authenticate!(:node_access_token)

        data = PacketsAtRest::PingableServer.routes["GET"].collect{|a| a[0..1]}

        if PacketsAtRest::ROLE == :collector
            data += PacketsAtRest::Collector.routes["GET"].collect{|a| a[0..1]}
            data = data.to_json
        elsif PacketsAtRest::ROLE == :node
            data += PacketsAtRest::Node.routes["GET"].collect{|a| a[0..1]}
            data = data.to_json
        else
            data = data.to_json
        end

        content_type :json
        return data
    end

    get '/ping', allows: [] do
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

    get '/plugins', allows: [] do
        env['warden'].authenticate!(:node_access_token)

        content_type :json
        begin
            plugins = []
            PacketsAtRest::Plugin.all.each {|plugin| plugins << JSON[plugin.to_json]}
            return plugins.to_json
        rescue
            return internalerror 'there was a problem listing the plugins'
        end
    end

    # This is the protected route, without the proper access token you'll be redirected.
    get '/protected', allows: [:api_key] do
        env['warden'].authenticate!(:admin_access_token)

        content_type :json
        { :message => "This is an authenticated request!" }.to_json
    end

    # This is the route that unauthorized requests gets redirected to.
    post '/unauthenticated', allows: [] do
        unauthorized "Sorry, this request can not be authenticated. Try again."
    end

    get '/*', allows: [] do
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
