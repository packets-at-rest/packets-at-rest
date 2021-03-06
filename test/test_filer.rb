# test.rb
require File.expand_path '../test_helper.rb', __FILE__
require 'fileutils'
require 'logger'

require_relative '../ext/util'
require_relative '../lib/filer/filer.rb'
require_relative 'config.rb'

class FilerTest < MiniTest::Unit::TestCase

  def setup
    @filer = PacketsAtRest::Filer::Filer.new({:simulate => true, :logger_io => '/dev/null'})
  end

  def test_filer_defaults
    assert_equal "test/data/pcap", @filer.capturedir
    assert_equal "test/data/filed", @filer.filerdir
    assert_equal "pcap", @filer.fileprefix
  end

  # return lockfile status
  def test_lock_file
    assert_equal false, @filer.locked?
  end

  def test_file_pcaps
    assert_equal ["test/data/filed/2015/05/22/18/"], @filer.file_pcaps
  end

end
