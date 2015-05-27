module PacketsAtRest

  def self.redef_without_warning(const, value)
      self.send(:remove_const, const) if self.const_defined?(const)
      self.const_set(const, value)
  end

  # directory in which daemonlogger writes files (daemonlogger -l option)
  redef_without_warning('CAPTUREDIR', 'test/data/pcap')

  # directory in which filer should file pcaps
  redef_without_warning('FILERDIR', 'test/data/filed')

  # daemonlogger capture file prefix (daemonlogger -n option)
  redef_without_warning('FILEPREFIX', 'pcap')

  # printf binary
  redef_without_warning('PRINTF', '/usr/bin/printf')

  # tcpdump binary
  redef_without_warning('TCPDUMP', '/usr/sbin/tcpdump')

  # node specification
  redef_without_warning('NODEFILE', 'test/nodes.conf')

  # api specification
  redef_without_warning('APIFILE', 'test/api.conf')

  # node request prefix
  redef_without_warning('REQUESTPREFIX', 'http://')

  # lock file to ensure single actions
  redef_without_warning('LOCKFILE', File.expand_path('../../tmp/filer.lock', __FILE__))

  # Are the sensors set to UTC instead of localtime?
  redef_without_warning('UTC', true)

end
