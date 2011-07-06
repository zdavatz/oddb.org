#!/usr/bin/env ruby
# ODDB::View::TestAddress -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/address'
require 'htmlgrid/button'

module ODDB
  module View

class StubVCardMethods
  include VCardMethods
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end
class TestVCardMethods < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :pointer => 'pointer')
    @view    = ODDB::View::StubVCardMethods.new(@model, @session)
  end
  def test_vcard
    assert_kind_of(HtmlGrid::Link, @view.vcard(@model))
  end
end
class TestSuggestedAddress < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {}
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', 
                        :fon => ['fon'],
                        :fax => ['fax'],
                        :plz => 'plz',
                        :city    => 'city',
                        :street  => 'street',
                        :number  => 'number',
                        :lines   => ['line'],
                        :message => 'message',
                        :type    => 'type',
                        :email_suggestion => 'email_suggestion'
                       )
    @view     = ODDB::View::SuggestedAddress.new(@model, @session)
  end
  def test_init_components
    assert_equal('top address-width list', @view.init_components)
  end
  def test_correct
    flexmock(@lnf, :_event_url => '_event_url')
    flexmock(@session, :zone => 'zone')
    flexmock(@model, :pointer => 'pointer')
    assert_kind_of(HtmlGrid::Button, @view.correct(@model))
  end
end

class TestAddress < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
 
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone => 'zone'
                       )
    @model   = flexmock('model', 
                        :fon => ['fon'],
                        :fax => ['fax'],
                        :plz => 'plz',
                        :city    => 'city',
                        :street  => 'street',
                        :number  => 'number',
                        :lines   => ['line'],
                        :message => 'message',
                        :type    => 'type',
                        :pointer => 'pointer',
                        :email_suggestion => 'email_suggestion'
                       )

    @view    = ODDB::View::Address.new(@model, @session)
  end
  def test_init_components
    assert_equal('top address-width list', @view.init_components)
  end
end

  end # View
end # ODDB

