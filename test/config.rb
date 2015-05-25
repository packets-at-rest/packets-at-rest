module PacketsAtRest

  # directory in which daemonlogger writes files (daemonlogger -l option)
  CAPTUREDIR = 'test/data/pcap'

  # directory in which filer should file pcaps
  FILERDIR = 'test/data/filed'

  # daemonlogger capture file prefix (daemonlogger -n option)
  FILEPREFIX = 'pcap'

  # printf binary
  PRINTF = '/usr/bin/printf'

  # tcpdump binary
  TCPDUMP = '/usr/sbin/tcpdump'

  # node specification
  NODEFILE = 'test/nodes.conf'

  # api specification
  APIFILE = 'test/api.conf'

  # node request prefix
  REQUESTPREFIX = 'http://'


    # lock file to ensure single actions
    LOCKFILE = File.expand_path('../../tmp/filer.lock', __FILE__)

    # Are the sensors set to UTC instead of localtime?
    UTC = false


end
