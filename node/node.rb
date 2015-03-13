require 'chronic'
require_relative '../lib/pingable_server'
require_relative '../config/config'
require_relative '../lib/util'

module PacketsAtRest

  class Node < PingableServer

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
      command = "#{PRINTF} \"#{files.join('\n')}\\n\" | #{TCPDUMP} -V - -w - \"#{filter}\""
      puts command

      if files.empty?
        return notfound 'no capture data for that timeframe'
      end

      content_type 'application/pcap'
      return [200, `#{command}`]
    end

    def filelist start_dt, end_dt
      # ensure boundary minutes are included by subtracting/adding a minute
      adj_start_dt = start_dt - 60
      adj_end_dt = end_dt + 60

      start_d = adj_start_dt.to_date
      end_d = adj_end_dt.to_date

      dirs = []

      if start_d == end_d
        (adj_start_dt.hour .. adj_end_dt.hour).each do |hour|
          dirs << "#{FILERDIR}/#{adj_start_dt.year}/#{adj_start_dt.month.pad2}/#{adj_start_dt.day.pad2}/#{hour.pad2}/"
        end
      else
        (adj_start_dt.hour .. 23).each do |hour|
          dirs << "#{FILERDIR}/#{adj_start_dt.year}/#{adj_start_dt.month.pad2}/#{adj_start_dt.day.pad2}/#{hour.pad2}/"
        end
        (start_d .. end_d).to_a[1...-1].each do |date|
          (0 .. 23).each do |hour|
            dirs << "#{FILERDIR}/#{date.year}/#{date.month.pad2}/#{date.day.pad2}/#{hour.pad2}/"
          end
        end
        (0 .. adj_end_dt.hour).each do |hour|
          dirs << "#{FILERDIR}/#{adj_end_dt.year}/#{adj_end_dt.month.pad2}/#{adj_end_dt.day.pad2}/#{hour.pad2}/"
        end
      end

      files = []

      if dirs.first == dirs.last
        Dir["#{dirs.first}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
        end
      else
        Dir["#{dirs.first}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
        end
        dirs.to_a[1...-1].each do |dir|
          Dir["#{dir}/*"].sort.each do |path|
            files << path
          end
        end
        Dir["#{dirs.last}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
        end
      end

      files
    end

  end

end
