# Stdlib
require 'uri'
require 'forwardable'

# Gems
require 'chronic'
require 'json'
require 'rest_client'

# Local Files
require_relative '../lib/pingable_server'
require_relative '../lib/controllers/collector'

module PacketsAtRest
  include Forwardable

  class Collector < PingableServer

    extend Forwardable
    helpers Sinatra::Param

    helpers do
      def_delegators :@collector, :valid_node?, :lookup_nodes_by_api_key, :lookup_nodeaddress_by_id, :lookup_nodeaddresses
    end

    before do
      begin
        @collector = PacketsAtRest::Controllers::Collector.new
        nodes = lookup_nodes_by_api_key(params['api_key'])

        if not nodes
          halt unauthorized 'unknown api_key'
        end
      rescue
        halt internalerror 'there was a problem checking api_key'
      end
    end

    get '/data.pcap', allows: [:src_addr, :src_port, :dst_addr, :dst_port, :start_time, :end_time, :api_key, :node_id] do

      param :src_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
      param :src_port,           Integer, min: 1, max: 65536, required: true
      param :dst_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
      param :dst_port,           Integer, min: 1, max: 65536, required: true
      param :start_time,         String, required: true
      param :end_time,           String, required: true
      param :api_key,             String, format: /^[a-zA-Z0-9\-]+$/, required: true
      param :node_id,             Integer, required: true


      packet_keys = ['src_addr', 'src_port', 'dst_addr', 'dst_port', 'start_time', 'end_time']
      other_keys = ['api_key', 'node_id']

      env['warden'].authenticate!(:node_access_token)
      return forbidden 'api_key not allowed to request this resource' unless @collector.authorized_nodes(params['api_key']).include?(params['node_id'].to_s)
      return badrequest 'unknown node' unless valid_node? params['node_id']

      begin
        node_address = lookup_nodeaddress_by_id(params['node_id'])

        query = (packet_keys << 'api_key').collect{ |k| "#{k}=#{params[k]}" }.join('&')
        uri = URI.encode("http://#{node_address}/data.pcap?#{query}")
        RestClient.get(uri) do |response, request, result|
          if response.code == 200
            content_type 'application/pcap'
          else
            content_type :json
          end
          return [response.code, response.body]
        end
      rescue
        return internalerror 'there was a problem requesting from the node'
      end
    end

    get '/keys', allows: [:api_key] do

      param :api_key,             String, format: /^[a-zA-Z0-9\-]+$/, required: true

      # Allow admin user
      env['warden'].authenticate!(:admin_access_token)

      content_type :json

      begin
        return JSON.parse(File.read(@collector.apifile)).to_json
      rescue
        return internalerror 'there was a problem looking up nodes'
      end
    end

    get '/nodes/list', allows: [:api_key] do

      param :api_key,             String, format: /^[a-zA-Z0-9\-]+$/, required: true

      # Allow any auth user
      env['warden'].authenticate!(:node_access_token)

      content_type :json

      begin
        return @collector.authorized_nodes(params['api_key']).to_json
      rescue
        return internalerror 'there was a problem getting node list'
      end
    end

    get '/nodes/:node_id/:command', allows: [:api_key, :node_id, :command] do

      param :api_key,             String, format: /^[a-zA-Z0-9\-]+$/, required: true
      param :command,             String, format: /^[a-zA-Z0-9\-]+$/, required: true
      param :node_id,             Integer, transform: :to_s, required: true

      content_type :json

      authorized_proxy_commands = [:ping, :status, :plugins, :routes]

      return badrequest 'this request is not supported' unless authorized_proxy_commands.include?(params['command'].to_sym)

      env['warden'].authenticate!(:node_access_token)
      return forbidden 'api_key not allowed to request this resource' unless @collector.authorized_nodes(params['api_key']).include?(params['node_id'])
      return badrequest 'unknown node' unless valid_node? params['node_id']

      begin
        node_address = lookup_nodeaddress_by_id(params['node_id'])

        uri = URI.encode("http://#{node_address}/#{params['command']}")
        RestClient.get(uri) do |response, request, result|
          [response.code, response.body]
        end
      rescue
        return internalerror 'there was a problem requesting from the node'
      end
    end

  end

end
