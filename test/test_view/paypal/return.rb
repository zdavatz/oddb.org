#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::PayPal::TestReturn -- oddb.org -- 20.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/paypal/return'

module ODDB
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version'
    end

    module PayPal
      class StubURI
      end
      class ReturnDownloads < HtmlGrid::List
        URI = StubURI.new
      end

class TestReturnDownloads < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :event      => 'event',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    @model   = flexmock('model', 
                        :expired? => nil,
                        :email    => 'email',
                        :oid      => 'oid',
                        :text     => 'text'
                       )
    @list    = ODDB::View::PayPal::ReturnDownloads.new([@model], @session)
  end
  def test_additional_download_link
    assert_equal(nil, @list.additional_download_link(@model))
  end
  def test_download_link
    assert_kind_of(HtmlGrid::Link, @list.download_link(@model))
  end
  def test_download_link__expired
    flexmock(@model, 
             :expired?    => true,
             :expiry_time => Time.local(2011,2.3)
            )
    assert_equal('lookup', @list.download_link(@model))
  end
end

class TestReturnComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @item    = flexmock('item', 
                        :text     => 'text',
                        :expired? => nil,
                        :email    => 'email',
                        :oid      => 'oid'
                       )
    @model   = flexmock('model', 
                        :payment_received? => nil,
                        :items => [@item]
                       )
  end
  def test_init
    composite = ODDB::View::PayPal::ReturnComposite.new(@model, @session)
    assert_equal({}, composite.init)
  end
  def test_init__nil
    composite = ODDB::View::PayPal::ReturnComposite.new(nil, @session)
    assert_equal({}, composite.init)
  end
  def test_init__download_protocol
    flexmock(@lnf, :_event_url => '_event_url')
    flexmock(@session, :event => 'event')
    flexmock(@model, :payment_received? => true)
    flexmock(@item, :text => 'stanza')
    uri = flexmock('uri', :scheme= => nil)
    flexmock(ODDB::View::PayPal::ReturnDownloads::URI, :parse => uri)
    composite = ODDB::View::PayPal::ReturnComposite.new(@model, @session)
    assert_equal({}, composite.init)

  end
  def test_init__payment_received
    flexmock(@lnf, :_event_url => '_event_url')
    flexmock(@session, :event => 'event')
    flexmock(@model, :payment_received? => true)
    composite = ODDB::View::PayPal::ReturnComposite.new(@model, @session)
    assert_equal({}, composite.init)
  end
end

class TestReturn < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :zones      => 'zones',
                         :event_url  => 'event_url',
                         :disabled?  => nil,
                         :_event_url => '_event_url',
                         :navigation => 'navigation',
                         :direct_event     => 'direct_event',
                         :zone_navigation  => 'zone_navigation'
                        )
    user      = flexmock('user', :valid? => nil)
    sponsor   = flexmock('sponsor', :valid? => nil)
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :user        => user,
                         :sponsor     => sponsor
                        )
    @model    = flexmock('model', :payment_received? => nil)
    @template = ODDB::View::PayPal::Return.new(@model, @session)
  end
  def test_http_headers
    flexmock(@model, :oid => 'oid')
    expected = {
      "P3P"           => "CP='OTI NID CUR OUR STP ONL UNI PRE'",
      "Refresh"       => "10; URL=event_url",
      "Pragma"        => "no-cache",
      "Content-Type"  => "text/html; charset=UTF-8", 
      "Cache-Control" => "private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
      "Expires"       => "Wed, 20 Apr 2011 09:16:39 GMT"
    }
    result = @template.http_headers
    assert_equal(expected['P3P'], result['P3P'])
    assert_equal(expected['Refresh'], result['Refresh'])
    assert_equal(expected['Pragma'], result['Pragma'])
    assert_equal(expected['Content-Type'], result['Content-Type'])
    assert_equal(expected['Cache-Control'], result['Cache-Control'])
  end
end


    end # PayPal
  end # View
end # ODDB

