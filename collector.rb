require 'sinatra/base'
require 'chronic'
require 'json'
require 'sys/uptime'
require 'rest_client'
require 'uri'
require_relative 'config'
require_relative 'util'

module PacketsAtRest

  class Collector < Sinatra::Base

    before do
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if not nodes
          halt unauthorized 'unknown api_key'
        end
      rescue
        halt internalerror 'there was a problem checking api_key'
      end
    end

    get '/data.pcap' do
      packet_keys = ['src_addr', 'src_port', 'dst_addr', 'dst_port', 'start_time', 'end_time']
      other_keys = ['api_key', 'node_id']
      missing_keys = (packet_keys + other_keys).select { |k| !params.key? k }
      if not missing_keys.empty?
        return badrequest "must provide missing parameters: #{missing_keys.join(', ')}"
      end

      nodes = lookup_nodes_by_api_key(params['api_key'])
      if !nodes.include? "0" and !nodes.include? params['node_id']
        return forbidden 'api_key not allowed to request this resource'
      end

      node_address = lookup_nodeaddress_by_id params['node_id']
      if not node_address
        return badrequest 'unknown node'
      end

      content_type 'application/pcap'
      query = (packet_keys << 'api_key').collect{ |k| "#{k}=#{params[k]}" }.join('&')
      uri = URI.encode("#{REQUESTPREFIX}#{node_address}/data.pcap?#{query}")
      puts uri
      return RestClient.get(uri).body
    end

    get '/keys' do
      content_type :json
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes.include? "0"
          return JSON.parse(File.read(APIFILE)).to_json
        else
          return forbidden 'api_key not allowed to request this resource'
        end
      rescue
        return internalerror 'there was a problem looking up nodes'
      end
    end

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

    get '/nodes/list' do
      content_type :json
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes.include? "0"
          return JSON.parse(File.read(NODEFILE)).to_json
        else
          return lookup_nodeaddresses.keep_if { |k, v| nodes.include? k }.to_json
        end
      rescue
        return internalerror 'there was a problem getting node list'
      end
    end

    get '/nodes/:id/ping' do
      content_type :json
      # ping node params[:id]
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

    def lookup_nodes_by_api_key api_key
      begin
        h = JSON.parse(File.read(APIFILE))
        return h[api_key]
      rescue
        nil
      end
    end

    def lookup_nodeaddress_by_id id
      begin
        h = JSON.parse(File.read(NODEFILE))
        return h[id]
      rescue
        nil
      end
    end

    def lookup_nodeaddresses
      begin
        return JSON.parse(File.read(NODEFILE))
      rescue
        nil
      end
    end

  end

end
