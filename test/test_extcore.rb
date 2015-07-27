# test.rb
require 'pry'
require File.expand_path '../test_helper.rb', __FILE__
require 'fileutils'
require 'logger'

require_relative '../ext/util'

module Foo
  module Faz
    class Bar
        def self.pass!
          return true
        end
    end
  end
end

class ExtTest < MiniTest::Unit::TestCase

  def setup
    #binding.pry
  end

  def test_foo_faz
    assert_equal ::Foo::Faz::Bar.pass!, true
  end

  def test_object_module_call_ruby19
    assert_equal Object.const_get19("Foo::Faz::Bar").send("pass!"), true
  end

end
