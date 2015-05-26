# test.rb
require File.expand_path '../test_helper.rb', __FILE__
require_relative '../app/node.rb'
require_relative 'config.rb'


class NodeTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    PacketsAtRest::Node
  end

  # /data.pcap
  def test_get_pcap_without_tuple
    get "/data.pcap"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert((json.key?('error') and json["error"] == "must provide all six parameters: src_addr, src_port, dst_addr, dst_port, start_time, end_time"), "must provide all six parameters")

  end

  def test_get_pcap
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-02-26 4pm&end_time=2015-02-26 4:05pm"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert((json.key? 'error' and json["error"] == "no capture data for that timeframe"), 'should return an error with a message')

  end

  def test_get_pcap_url
    # TODO
  end

  # /ping
  def test_get_ping_without_api_key
    get "/ping"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert('should return uptime and date') {
      json.key? 'uptime' and json.key? 'date' and json.key? 'version' and json.key? 'api_version'
    }
  end

end
