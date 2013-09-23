#!/usr/bin/env ruby
# ODDB::MedData::TestDRbSession -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'meddparser'
require 'drbsession'
require 'result'
require 'meddata'

module ODDB
  module MedData

class TestDRbSession <Minitest::Test
  include FlexMock::TestCase
  def setup
    @drb = ODDB::MedData::DRbSession.new(:partner)
  end
  def test_remove_whitespace
    data = {'key' => 'value'}
    assert_equal(data, @drb.remove_whitespace(data))
  end
  def test__dispatch
    @drb._dispatch(['ctl', ['value']]) do |result|
      assert_kind_of(ODDB::MedData::Result, result)
    end
  end
  def test__dispatch__nil
    assert_kind_of(Array, @drb._dispatch(['ctl', ['value']]))
  end
  def test_detail
    result = flexmock('result', :ctl => 'ctl')
    expected = {"key" => "EAN-Code (GLN)"}
    assert_equal(expected, @drb.detail(result, {'key' => [0,0]}))
  end
  def test_search__error
    assert_raise(MedData::OverflowError) do 
      @drb.search('criteria') do |dispatch|
      end
    end
  end
  def test_search
    flexmock(@drb.instance_eval('@session')).should_receive(:get_result_list).and_return('<html></html>')
    @drb.search('criteria') do |dispatch|
    end
  end
end

  end # MedData
end # ODDB
