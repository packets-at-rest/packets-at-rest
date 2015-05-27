# test.rb
require File.expand_path '../test_helper', __FILE__
require_relative '../ext/util'
require_relative '../lib/controllers/node'
require_relative 'config'


class NodeControllerTest < MiniTest::Unit::TestCase

  # /data.pcap
  def test_node_controller
    @node = ::PacketsAtRest::Controllers::Node.new
    filelist = @node.filelist(Time.at(1424964400).utc, Time.at(1424970700).utc)
    assert_equal ["test/data/filed/2015/02/26/15//pcap.1424966573"], filelist
  end

  def test_node_controller_no_files
    @node = PacketsAtRest::Controllers::Node.new
    filelist = @node.filelist(Time.at(1324984400).utc, Time.at(1324984700).utc)
    assert_equal [], filelist
  end

end
