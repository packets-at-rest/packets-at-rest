# Stdlib
require 'forwardable'

# Gems
require 'chronic'
require 'json'

# Local Files
require_relative '../lib/pingable_server'
require_relative '../lib/controllers/node'

module PacketsAtRest
  include Forwardable

  class Node < PingableServer

    extend Forwardable
    helpers Sinatra::Param

    helpers do
        def_delegators :@node, :filelist
    end

    before do
      @node = PacketsAtRest::Controllers::Node.new
    end


    get '/data.pcap', allows: [:src_addr, :src_port, :dst_addr, :dst_port, :start_time, :end_time] do
      param :src_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
      param :src_port,           Integer, min: 1, max: 65536, required: true
      param :dst_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
      param :dst_port,           Integer, min: 1, max: 65536, required: true
      param :start_time,         String, required: true
      param :end_time,           String, required: true

      invalid_msg = ''
      start_dt = Chronic.parse(params['start_time'])
      invalid_msg += 'invalid start time. ' if start_dt == nil

      end_dt = Chronic.parse(params['end_time'])
      invalid_msg += 'invalid end time. ' if end_dt == nil

      if not invalid_msg.empty?
        return badrequest invalid_msg.chop
      end

      bpf_filter = "host #{params['src_addr']} and host #{params['dst_addr']} and port #{params['src_port']} and port #{params['dst_port']}"
      files = filelist(start_dt, end_dt)


      command = "#{PRINTF} \"#{files.join('\n')}\\n\" | #{TCPDUMP} -V - -w - \"#{bpf_filter}\" 2> /dev/null"

      puts command unless PacketsAtRest::ROLE == :unit_test

      if files.empty?
        return notfound 'no capture data for that timeframe'
      end

      content_type 'application/pcap'
      return [200, `#{command}`]
    end

    get '/status', allows: [] do
      content_type :json
      begin
        return {
          "hostname" => `hostname -f`.strip,
          "capturedir" => PacketsAtRest::CAPTUREDIR,
          "filerdir" => PacketsAtRest::FILERDIR,
          "du" => {
              "filerdir" => `du -hd 0 #{PacketsAtRest::FILERDIR}`.strip,
              "capturedir" => `du -hd 0 #{PacketsAtRest::CAPTUREDIR}`.strip
          },
          "df" => {
              "filerdir" => `df -h #{PacketsAtRest::FILERDIR} |tail -1`.strip,
              "capturedir" => `df -h #{PacketsAtRest::CAPTUREDIR} |tail -1`.strip
          },
          "netstat" => {
              "daemonlogger" => `netstat -B |grep daemon`.strip
          },
          "system_date" => `date`.strip,
          "ruby_utc_datetime" => Time.now.utc
        }.to_json
      rescue
        return internalerror 'there was a problem getting status'
      end
    end

  end

end
