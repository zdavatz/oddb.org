#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPatinfoStats -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/patinfo_stats'


module ODDB
  module View
    module Admin

class TestPatinfoStatsCompanyList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event => 'event'
                       )
    item     = flexmock('item', :time => Time.utc(2011,2,3))
    sequence = flexmock('sequence', 
                        :pointer => 'pointer',
                        :invoice_items => [item]
                       )
    @model   = flexmock('model', 
                        :time    => Time.utc(2011,2,3),
                        :pointer => 'pointer',
                        :slate_sequences => [sequence],
                        :ean13   => 'ean13'
                       )
    @view    = ODDB::View::Admin::PatinfoStatsCompanyList.new([@model], @session)
  end
  def test_date
    assert_equal('Thursday 03.02.2011 &nbsp;&nbsp;-&nbsp;&nbsp;00.00 Uhr UTC', @view.date(@model, @session))
  end
end


    end # Admin
  end # View
end # ODDB
