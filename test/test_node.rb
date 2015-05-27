# test.rb
require File.expand_path '../test_helper', __FILE__
require_relative '../app/node'
require_relative 'config'

class NodeTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    PacketsAtRest::Node
  end

  # /data.pcap
  def test_get_pcap_without_tuple
    get "/data.pcap"
    assert(!last_response.ok?, 'should not be ok')
    assert((last_response.body == "Parameter must be a string if using the format validation"), "must provide all six parameters")
  end

  def test_get_pcap_missing
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-01-26 4pm&end_time=2015-01-26 4:05pm"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert((json.key? 'error' and json["error"] == "no capture data for that timeframe"), 'should return an error with a message')
  end

  def test_get_pcap_invalid_parameter
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=-99999&dst_addr=2.2.2.2&dst_port=2&start_time=2015-01-26 4pm&end_time=2015-01-26 4:05pm"
    assert(!last_response.ok?, 'should not be ok')
    assert((last_response.body == "Parameter cannot be less than 1"), "must provide valid")
  end


  def test_get_pcap
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-02-26 4pm&end_time=2015-02-26 4:05pm"
    assert((last_response.header["Content-Type"] == "application/pcap"), 'should return an actual pcapfile')
  end


  # /ping
  def test_get_ping_without_api_key
    get "/ping"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert((json.key?('uptime') and json.key?('date') and json.key?('version') and json.key?('api_version') and json.key?('role')), 'should return uptime and date')
  end

end
