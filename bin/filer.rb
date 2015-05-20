require 'fileutils'
require_relative 'config'
require_relative 'util'

module PacketsAtRest

  def PacketsAtRest.file_pcaps

    # act on all files except the last (the one that daemonlogger is currently writing to)
    Dir["#{CAPTUREDIR}/#{FILEPREFIX}.*"].sort[0...-1].each do |filepath|
      file = File.basename(filepath)
      unixtime = file.sub(/#{FILEPREFIX}\./, '').to_i
      datetime = Time.at(unixtime)
      puts "Moving #{file} (#{datetime})"
      newpath = "#{FILERDIR}/#{datetime.year}/#{datetime.month.pad2}/#{datetime.day.pad2}/#{datetime.hour.pad2}/"
      FileUtils.mkpath_p(newpath)
      FileUtils.mv(filepath, newpath)
    end
  end

  PacketsAtRest.file_pcaps

end
