# Stdlib
require 'forwardable'

# Gems
require 'chronic'
require 'json'

# Local Files
require_relative '../lib/version'
require_relative '../lib/pingable_server'
require_relative '../lib/controllers/node'
require_relative '../config/config'
require_relative '../ext/util'


module PacketsAtRest
  include Forwardable

  class Node < PingableServer
    extend Forwardable

    helpers do
        def_delegators :@node, :filelist
    end

    before do
      @node = PacketsAtRest::Controllers::Node.new
    end


    get '/data.pcap' do
      keys = ['src_addr', 'src_port', 'dst_addr', 'dst_port', 'start_time', 'end_time']
      if not keys.reduce(true){ |memo, param| memo && params.key?(param) }
        return badrequest 'must provide all six parameters: src_addr, src_port, dst_addr, dst_port, start_time, end_time'
      end

      # input validation
      valid_msg = ''
      src_port = nil
      begin
        src_port = Integer(params['src_port'], 10)
      rescue
      end
      valid_msg += 'invalid source port. ' if src_port == nil or src_port < 0 or src_port > 65535
      dst_port = nil
      begin
        dst_port = Integer(params['dst_port'], 10)
      rescue
      end
      valid_msg += 'invalid destination port. ' if dst_port == nil or dst_port < 0 or dst_port > 65535
      start_dt = Chronic.parse(params['start_time'])
      valid_msg += 'invalid start time. ' if start_dt == nil
      end_dt = Chronic.parse(params['end_time'])
      valid_msg += 'invalid end time. ' if end_dt == nil
      if not valid_msg.empty?
        return badrequest valid_msg.chop
      end

      filter = "host #{params['src_addr']} and host #{params['dst_addr']} and port #{params['src_port']} and port #{params['dst_port']}"
      files = filelist(start_dt, end_dt)
      command = "#{PRINTF} \"#{files.join('\n')}\\n\" | #{TCPDUMP} -V - -w - \"#{filter}\" 2> /dev/null"

      puts command unless PacketsAtRest::ROLE == :unit_test

      if files.empty?
        return notfound 'no capture data for that timeframe'
      end

      content_type 'application/pcap'
      return [200, `#{command}`]
    end



  end

end
