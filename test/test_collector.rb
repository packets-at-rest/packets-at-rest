require 'test/unit'
require 'rack/test'
require_relative '../collector.rb'
require_relative 'config.rb'

class CollectorTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PacketsAtRest::Collector
  end

  MASTERKEY = '54b22f56-9a84-4893-bc70-332e3b5ded66'
  ONEKEY = '096dbfe4-a38f-4495-a0f4-f852dc982d50'
  TWOKEY = '27ee688c-c412-43f8-ad67-ee5287b59e80'

  # /data.pcap
  def test_get_pcap_without_api_key
    get "/data.pcap"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_pcap_without_node_id
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-02-26 4pm&end_time=2015-02-26 4:05pm&api_key=#{MASTERKEY}"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_pcap_without_access_to_node
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-02-26 4pm&end_time=2015-02-26 4:05pm&api_key=#{ONEKEY}&node_id=2"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_pcap_for_unknown_node
    get URI.encode "/data.pcap?src_addr=1.1.1.1&src_port=1&dst_addr=2.2.2.2&dst_port=2&start_time=2015-02-26 4pm&end_time=2015-02-26 4:05pm&api_key=#{MASTERKEY}&node_id=10"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_pcap_url
    # TODO
  end

  # /keys
  def test_get_keys_without_api_key
    get "/keys"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_keys_with_master_api_key
    get "/keys?api_key=#{MASTERKEY}"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert_block('should return all keys') {
      json.count == 4 and json.key? '27ee688c-c412-43f8-ad67-ee5287b59e80'
    }
  end

  # /ping
  def test_get_ping_without_api_key
    get "/ping"
    json = JSON.parse(last_response.body)
    assert(!last_response.ok?, 'should not be ok')
    assert_block('should return an error with a message') {
      json.key? 'error'
    }
  end

  def test_get_ping_with_master_api_key
    get "/ping?api_key=#{MASTERKEY}"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert_block('should return uptime and date') {
      json.key? 'uptime' and json.key? 'date'
    }
  end

  # /nodes/list
  def test_get_node_list_with_master_api_key
    get "/nodes/list?api_key=#{MASTERKEY}"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert_block('should return keys it has access to') {
      json.count == 2 and json.key? '1' and json.key? '2'
    }
  end

  def test_get_node_list_with_limited_api_key
    get "/nodes/list?api_key=#{ONEKEY}"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert_block('should return key it has access to') {
      json.count == 1 and json.key? '1'
    }
    assert_block('should not return key it does not have access to') {
      json.count == 1 and !json.key? '2' and !json.key? '0'
    }
  end

  def test_get_node_list_with_another_limited_api_key
    get "/nodes/list?api_key=#{TWOKEY}"
    json = JSON.parse(last_response.body)
    assert(last_response.ok?, 'should be ok')
    assert_block('should return keys it has access to') {
      json.count == 2 and json.key? '1' and json.key? '2'
    }
  end

end
