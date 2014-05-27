#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Remote::TestPackage -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock/test_unit'
require 'remote/package'

module ODDB
  module Remote

class Test <Minitest::Test
  include FlexMock::TestCase
  def setup
    @remote  = flexmock('remote', 
                        :comparable_size => 'comparable_size',
                        :sequence => 'sequence',
                        :size => 'size'
                       )
    @package = ODDB::Remote::Package.new(@remote)
  end
  def test_comparable_size
    assert_equal('comparable_size', @package.comparable_size)
  end
  def test_sequence
    assert_kind_of(ODDB::Remote::Sequence, @package.sequence)
  end
  def test_size
    assert_equal('size', @package.size)
  end
  def test_comparable
    flexmock(@remote, :comparable_size => [1])
    other = flexmock('other', :comparable_size => 1)
    skip("Don't know howto test comparable")
    assert(@package.comparable?(other))
  end
end

  end # Remote
end # ODDB

