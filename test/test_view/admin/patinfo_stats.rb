#!/usr/bin/env ruby
# ODDB::View::Admin::TestPatinfoStats -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/patinfo_stats'


module ODDB
  module View
    module Admin

class TestPatinfoStatsCompanyList < Test::Unit::TestCase
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
    item     = flexmock('item', :time => Time.local(2011,2,3))
    sequence = flexmock('sequence', 
                        :pointer => 'pointer',
                        :invoice_items => [item]
                       )
    @model   = flexmock('model', 
                        :time    => Time.local(2011,2,3),
                        :pointer => 'pointer',
                        :slate_sequences => [sequence]
                       )
    @view    = ODDB::View::Admin::PatinfoStatsCompanyList.new([@model], @session)
  end
  def test_date
    assert_equal('Thursday 03.02.2011 &nbsp;&nbsp;-&nbsp;&nbsp;00.00 Uhr CET', @view.date(@model, @session))
  end
end


    end # Admin
  end # View
end # ODDB
