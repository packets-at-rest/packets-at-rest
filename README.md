# packets-at-rest

## Environment and Dependencies
Suggested operating system is FreeBSD.

System dependencies include:
* net/daemonlogger

## Usage
Start daemonlogger. For example:

 daemonlogger -i em0 -l /data/pcap/ -n pcap -t 60

Edit options in config.rb. For example:

 CAPTUREDIR = '/data/pcap'
 FILERDIR = '/data/filed'
 FILEPREFIX = 'pcap'
 PRINTF = '/usr/bin/printf'
 TCPDUMP = '/usr/sbin/tcpdump'

Schedule the filer. For example, in crontab:

 * * * * * /usr/local/bin/ruby /git/packets-at-rest/filer.rb

Start the server. For example:

 rackup -p 9001

Make a request. For example:

 http://localhost:9001/data.pcap?src_addr=1.1.1.1&src_port=111&dst_addr=2.2.2.2&dst_port=222&start_time=2001-01-01 5:01pm&end_time=2001-01-01 5:05pm
