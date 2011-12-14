#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestLimit -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/errormessage'
require 'view/limit'
require 'htmlgrid/inputradio'

module ODDB
  module View
    class StubSession
      QUERY_LIMIT = 'query_limit'
    end

class TestLimitForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :format_price => 'format_price',
                        :base_url   => 'base_url'
                       )
    state    = flexmock('state', :price => 1.23)
    session  = StubSession.new
    @session = flexmock(session, 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :state       => state,
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::LimitForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
end

class TestLimitComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :format_price => 'format_price',
                        :base_url   => 'base_url'
                       )
    state    = flexmock('state', :price => 1.23)
    session  = StubSession.new
    @session = flexmock(session, 
                        :lookandfeel => @lnf,
                        :remote_ip   => 'remote_ip',
                        :error       => 'error',
                        :state       => state,
                        :warning?    => nil,
                        :error?      => nil,
                        :cookie_set_or_get => 'cookie_set_or_get'
                       )
    @model   = flexmock('model')

    @composite = ODDB::View::LimitComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
end

  end # View
end # ODDB
