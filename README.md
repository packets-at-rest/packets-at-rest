# packets-at-rest

Packets at Rest is a RESTful web interface to pcap data on distributed network sensors through the use of IPFIX flow tuples and simple API rolebased access controls.

## Build Status

[![Build Status](https://travis-ci.org/packets-at-rest/packets-at-rest.svg)](https://travis-ci.org/packets-at-rest/packets-at-rest)
[![Code Climate](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/gpa.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)
[![Test Coverage](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/coverage.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)

## Environment and Dependencies
Suggested operating system is FreeBSD.

System dependencies include:
* net/daemonlogger

## Usage

### Node
Start daemonlogger. For example:

```shell
daemonlogger -i em0 -l /data/pcap/ -n pcap -t 60
```

Edit options in config.rb. For example:

```
CAPTUREDIR = '/data/pcap' # daemonlogger -l option
FILERDIR = '/data/filed'
FILEPREFIX = 'pcap' # daemonlogger -n option
````

Schedule the filer. For example, in crontab:

```cron
* * * * * /usr/local/bin/ruby /git/packets-at-rest/filer.rb
```

Start the node. For example:

```shell
rackup node.ru -p 9002
```

### Collector

Edit APIFILE (api.conf) to give API keys access to nodes. API key with access to node "0" has access to all nodes. For example:

```json
{
    "54b22f56-9a84-4893-bc70-332e3b5ded66" : [ "0" ]
}
```

Edit NODEFILE (nodes.conf) to associate node numbers with their addresses. For example:

```json
{
    "1" : "127.0.0.1:9002"
}
```

Start the collector. For example:

```shell
rackup collector.ru -p 9001
```

Make a request. For example:

```
http://127.0.0.1:9001/data.pcap?src_addr=1.1.1.1&src_port=111&dst_addr=2.2.2.2&dst_port=222&start_time=2001-01-01 5:01pm&end_time=2001-01-01 5:05pm&api_key=54b22f56-9a84-4893-bc70-332e3b5ded66&node_id=1
```

### Data Flow

![diagram](https://raw.github.com/shadowbq/packets-at-rest/screenshots/diagram.png)
