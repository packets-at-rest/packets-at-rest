module PacketsAtRest

  # directory in which daemonlogger writes files (daemonlogger -l option)
  CAPTUREDIR = '/data/pcap'

  # directory in which filer should file pcaps
  FILERDIR = '/data/filed'

  # daemonlogger capture file prefix (daemonlogger -n option)
  FILEPREFIX = 'pcap'

  # printf binary
  PRINTF = '/usr/bin/printf'

  # tcpdump binary
  TCPDUMP = '/usr/sbin/tcpdump'

  # node specification
  NODEFILE = 'config/nodes.conf'

  # api specification
  APIFILE = 'config/api.conf'

  # lock file to ensure single actions
  LOCKFILE = File.expand_path('../../tmp/filer.lock', __FILE__)

  # Are the sensors set to UTC instead of localtime?
  UTC = false

end
