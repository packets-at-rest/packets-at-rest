# packets-at-rest

[![GitHub release](https://img.shields.io/github/tag/packets-at-rest/packets-at-rest.svg)](https://github.com/packets-at-rest/packets-at-rest)
[![API version](https://img.shields.io/badge/api-0.1.3-aa00aa.svg)](https://github.com/packets-at-rest/packets-at-rest/blob/master/lib/version.rb)

Packets at Rest is a RESTful web interface to pcap data on distributed network sensors through the use of IPFIX flow tuples and simple API rolebased access controls.

## Build Status

[![Build Status](https://travis-ci.org/packets-at-rest/packets-at-rest.svg)](https://travis-ci.org/packets-at-rest/packets-at-rest)
[![Code Climate](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/gpa.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)
[![Test Coverage](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/coverage.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)
[![Dependency Status](https://gemnasium.com/packets-at-rest/packets-at-rest.svg)](https://gemnasium.com/packets-at-rest/packets-at-rest)

## Environment, Dependencies, and Deployment Considerations
The Suggested operating system is FreeBSD for `node` for high efficiency capture.

The Suggested operating system for `collector` is any modern *nix operating system.

General System dependencies include:
* Ruby
* Bundler
* Rack based webserver

`node` System dependencies include:
* daemonlogger
* tcpdump
* printf

### Dependency Information

The Ruby based Web API is powered by sinatra and rack.

* http://www.sinatrarb.com/
* http://rack.github.io/

Packets-at-REST recommends a quality well test SSL web server like nginx with phusion passenger.
* https://www.phusionpassenger.com/
* http://wiki.nginx.org/Main
* [NGINX+Phusion Passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html)

Although the Collector and the Node can exist on the same server we recommend a HA of Collectors with x-N Nodes. Collectors in a HA configuration are not aware of each other, and should be targeted via Round Robin DNS queries.

* [Round Robin DNS Load Balancing](https://www.digitalocean.com/community/tutorials/how-to-configure-dns-round-robin-load-balancing-for-high-availability)


## Installation

```shell
$> wget https://github.com/packets-at-rest/packets-at-rest/archive/0.2.0.zip
$> unzip 0.2.0.zip /opt/
$> cd /opt/packets-at-rest/
$> bundle install --without test
```

Ensure that rake list task is working

```shell
$> rake -T
rake bump:current    # Show current gem version
rake bump:major      # Bump major part of gem version
rake bump:minor      # Bump minor part of gem version
rake bump:patch      # Bump patch part of gem version
rake bump:pre        # Bump pre part of gem version
rake release         # release TAG 0.1.1 to github
rake role_collector  # Set Role Collector
rake role_node       # Set Role Node
rake test            # Run tests
```

Setup the mode (node|collector) for the server.

```
$> rake role_collector
```

### Node

The node is responsible for capturing the network data, storing it, and making it available to the 'node' webapp api.

Start daemonlogger. For example:

```shell
daemonlogger -i em0 -l /data/pcap/ -n pcap -t 60
```

Edit options in `config/config.rb`. For example:

```
CAPTUREDIR = '/data/pcap' # daemonlogger -l option
FILERDIR = '/data/filed'
FILEPREFIX = 'pcap' # daemonlogger -n option
````

Setup your [ALPACA](https://github.com/jeffchao/alpaca) **RACK-Based ACLs** configuration for your node.

It is recommended to only accept connections from the Collectors IP/Host addresses.

The configuration file should be located in config/alpaca.yml

```yml
whitelist:
  - 127.0.0.1
  - "::/128"
  - 10.0.0.0/8
blacklist:
  - 8.8.8.8
default: deny
```

### Setup Filer on each Node

Schedule the `filer`. For example, in crontab:

```cron
* * * * * /usr/local/bin/ruby /opt/packets-at-rest/bin/filer
```

The `filer` can be simulated using the -S flag.

```shell
$> ./bin/filer.rb -S
I, [2015-05-25T00:09:20.438741 #17996]  INFO -- : Program started.
I, [2015-05-25T00:09:20.439001 #17996]  INFO -- : scanning /data/pcap/pcap.*
I, [2015-05-25T00:09:20.439138 #17996]  INFO -- : Processing: pcap.1432516781
I, [2015-05-25T00:09:20.439290 #17996]  INFO -- : Moving /data/pcap/pcap.1432516781 => /data/filed/2015/05/24/21/
I, [2015-05-25T00:09:20.439382 #17996]  INFO -- : Processing: pcap.1432526781
I, [2015-05-25T00:09:20.439501 #17996]  INFO -- : Moving /data/pcap/pcap.1432526781 => /data/filed/2015/05/25/00/
I, [2015-05-25T00:09:20.439573 #17996]  INFO -- : Processing: pcap.1432526782
I, [2015-05-25T00:09:20.439689 #17996]  INFO -- : Moving /data/pcap/pcap.1432526782 => /data/filed/2015/05/25/00/
I, [2015-05-25T00:09:20.439862 #17996]  INFO -- : /home/shadowbq/sandbox/github-shadowbq/packets-at-rest/tmp/filer.lock removed.
I, [2015-05-25T00:09:20.439924 #17996]  INFO -- : Program completed.

```

Start the node. For example:

```shell
rake role_node
rackup config.ru -p 9002
```

### Collector

API keys must be made for each REST client attempting to access the Packets-at-Rest system. API keys are UUID codes. You can create a secure UUID with ruby.

```ruby
$> irb
2.1.2 :001 > require 'securerandom'
 => true
2.1.2 :002 > SecureRandom.uuid
 => "54b22f56-9a84-4893-bc70-332e3b5ded66"
```

Edit APIFILE `config/api.conf` to give API keys access to nodes. API keys with access to node "0" have access to all nodes and key information. For example:

```json
{
    "54b22f56-9a84-4893-bc70-332e3b5ded66" : [ "0" ],
    "d5c3d52e-d42c-41ff-bbfa-d3e802770ee1" : [ "1", "2" ],
    "ce34b5ac-df85-40f0-9500-2a4a7781a6c4" : [ "2" ]
}
```

Edit NODEFILE `config/nodes.conf` to associate node numbers with their addresses. For example:

```json
{
    "1" : "127.0.0.1:9002",
    "2" : "10.0.0.2:9002"
}
```

Start the collector. For example:

```shell
rake role_collector
rackup config.ru -p 9001
```

Make a request. For example:

```
http://127.0.0.1:9001/data.pcap?src_addr=1.1.1.1&src_port=111&dst_addr=2.2.2.2&dst_port=222&start_time=2001-01-01 5:01pm&end_time=2001-01-01 5:05pm&api_key=54b22f56-9a84-4893-bc70-332e3b5ded66&node_id=1
```

## The API

Getting Information from the `collector`.

### Ping

`https://10.0.0.2/ping?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66`

```json
{
  version: "0.6.2",
  api_version: "0.1.2",
  uptime: "0:4:5:13",
  date: "2015-05-27 18:31:22 UTC",
  role: "collector"
}
```

`https://10.0.0.2/nodes/1/ping?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66`

```json
{
  version: "0.6.2",
  api_version: "0.1.2",
  uptime: "106:3:30:46",
  date: "2015-05-27 18:27:24 UTC",
  role: "node"
}
```

### Status

`https://10.0.0.2/nodes/1/status?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66`

```json
{
  hostname: "sensor-1.nowhere.org",
  capturedir: "/data/pcap",
  filerdir: "/data/filed",
  du: {
    filerdir: "4.0k	/data/filed",
    capturedir: "4.0k	/data/pcap"
  },
  df: {
    filerdir: "/dev/mfid0p3 7.7G 4.1G 3G 58% /",
    capturedir: "/dev/mfid0p3 7.7G 4.1G 3G 58% /"
  },
  netstat: {
    daemonlogger: "626 bce1 p--s--- 16297985219 47 595580784 0 0 daemonlogger"
  },
  system_date: "Wed May 27 18:22:12 UTC 2015",
  ruby_utc_datetime: "2015-05-27 18:22:12 UTC"
}
```

### Node listing

`https://10.0.0.2/nodes/list?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66`

```json
{
  1: "120.18.0.151",
  2: "120.18.0.152:9000",
  3: "120.18.0.153",
  4: "120.18.0.154:9000"
}
```
### Keys

Query access controls

`https://10.0.0.2/keys?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66`

```json
{
  54b22f56-9a84-4893-bc70-332e3b5ded66: [
    "0"
  ],
  d5c3d52e-d42c-41ff-bbfa-d3e802770ee1: [
    "1",
    "2",
    "3"
  ],
  ce34b5ac-df85-40f0-9500-2a4a7781a6c4: [
    "1",
    "3",
    "4"
  ]
}
```

### PCAP Data

```shell
https://10.0.0.2/data.pcap?src_addr=1.1.1.1&src_port=111&dst_addr=2.2.2.2&dst_port=222&start_time=2001-01-01 5:01pm&end_time=2001-01-01 5:05pm&api_key=54b22f56-9a84-4893-bc70-332e3b5ded66&node_id=1
```

Requests should be well formed:

```ruby
  param :src_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
  param :src_port,           Integer, min: 1, max: 65536, required: true
  param :dst_addr,           String, format: /^[a-zA-Z0-9.:]+$/, required: true
  param :dst_port,           Integer, min: 1, max: 65536, required: true
  param :start_time,         String, required: true
  param :end_time,           String, required: true
  param :api_key,             String, format: /^[a-zA-Z0-9\-]+$/, required: true
  param :node_id,             Integer, required: true
```

Response headers include:

`:content_type => application/pcap`

PCAP files applications such as [Wireshark](https://www.wireshark.org/) can be associated to automagically open on download of pcapfile.

### PCAP vs PCAPNG

Standard pcap files with "pcapfile magic number = `\xd4\xc3\xb2\xa1`" have been around for many years. Newer [pcapng](https://wiki.wireshark.org/Development/PcapNg) files can be read by *wireshark*, *tcpdump*, etc.. but are not always available.

Proper MIME type for standard PCAP
`application/vnd.tcpdump.pcap; charset=binary`

### Magic Number Matching

Standard PCAP
`tcpdump capture file (little-endian) [application/vnd.tcpdump.pcap]`

NextGeneration PCAPs (.pcapng)
`extended tcpdump capture file (little-endian) []`

### Data Flow

![diagram](https://raw.github.com/packets-at-rest/packets-at-rest/cdn-images/diagram.png)


## Plug-ins

Packets at REST supports plug-ins. Plugins should be installed into the `/plugins` dir.

Each plugin must register with the main application.

* See (packets-at-rest/par_plugin_facter)[https://github.com/packets-at-rest/par_plugin_facter] for an example.
* See plugins/README.md for more information.

The plugin class must be `Plugin`

## API

Collector

`https://10.0.0.2/plugins`

Access Controls:

~~ https://10.0.0.2/plugins?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66 ~~
~~ https://10.0.0.2/nodes/1/plugins?api_key=54b22f56-9a84-4893-bc70-332e3b5ded66~~

Node

`https://10.0.0.90/plugins`

```json
[
    {
        id: "par_plugin_facter",
        name: "Facter plugin for Packets At REST",
        description: "returns json output of the facter gem for system information",
        url: "http://github.com/packets-at-rest/par_plugin_facter",
        author: "shadowbq",
        author_url: "mailto:shadowbq@gmail.com",
        version: "0.1.2",
        settings: null,
        directory: null
    }
]
```
