require 'sinatra/base'
require 'chronic'
require 'json'

require_relative 'config'

module PacketsAtRest

  class Server < Sinatra::Base

    get '/data.pcap' do
      keys = ['src_addr', 'src_port', 'dst_addr', 'dst_port', 'start_time', 'end_time']
      if not keys.reduce(true){ |memo, param| memo && params.key?(param) }
        content_type 'text/html'
        return [404, 'must provide all six parameters: src_addr, src_port, dst_addr, dst_port, start_time, end_time']
      end

      filter = "host #{params['src_addr']} and host #{params['dst_addr']} and port #{params['src_port']} and port #{params['dst_port']}"
      files = PacketsAtRest.filelist(params['start_time'], params['end_time'])
      command = "#{PRINTF} \"#{files.join('\n')}\\n\" | #{TCPDUMP} -V - -w - \"#{filter}\""
      puts command

      content_type 'application/pcap'
      return [200, `#{command}`]
    end

    get '/*' do
      content_type 'text/html'
      return [400, 'request data from /data.pcap']
    end

    def PacketsAtRest.filelist start_str, end_str
      # ensure boundary minutes are included by subtracting/adding a minute
      start_dt = Chronic.parse(start_str) - 60
      end_dt = Chronic.parse(end_str) + 60

      start_d = start_dt.to_date
      end_d = end_dt.to_date

      dirs = []

      if start_d == end_d
        (start_dt.hour .. end_dt.hour).each do |hour|
          dirs << "#{FILERDIR}/#{start_dt.year}/#{start_dt.month}/#{start_dt.day}/#{hour}/"
        end
      else
        (start_dt.hour .. 23).each do |hour|
          dirs << "#{FILERDIR}/#{start_dt.year}/#{start_dt.month}/#{start_dt.day}/#{hour}/"
        end
        (start_d .. end_d).to_a[1...-1].each do |date|
          (0 .. 23).each do |hour|
            dirs << "#{FILERDIR}/#{date.year}/#{date.month}/#{date.day}/#{hour}/"
          end
        end
        (0 .. end_dt.hour).each do |hour|
          dirs << "#{FILERDIR}/#{end_dt.year}/#{end_dt.month}/#{end_dt.day}/#{hour}/"
        end
      end

      files = []

      if dirs.first == dirs.last
        Dir["#{dirs.first}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= start_dt.to_i and unixtime <= end_dt.to_i
        end
      else
        Dir["#{dirs.first}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= start_dt.to_i and unixtime <= end_dt.to_i
        end
        dirs.to_a[1...-1].each do |dir|
          Dir["#{dir}/*"].sort.each do |path|
            files << path
          end
        end
        Dir["#{dirs.last}/*"].sort.each do |path|
          file = File.basename(path)
          unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
          files << path if unixtime >= start_dt.to_i and unixtime <= end_dt.to_i
        end
      end

      files
    end
    
  end

end
