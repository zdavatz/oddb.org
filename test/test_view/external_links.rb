#!/usr/bin/env ruby
# ODDB::View::TestExternalLinks -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/navigationlink'
require 'view/external_links'
require 'htmlgrid/popuplink'

module ODDB
  module View
    
class StubExternalLinks
  include ODDB::View::ExternalLinks
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end

class TestStubExternalLinks < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :enabled?   => nil,
                        :direct_event => 'direct_event'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @links   = ODDB::View::StubExternalLinks.new(@model, @session)
  end
  def test_contact_link
    assert_kind_of(ODDB::View::NavigationLink, @links.contact_link(@model, @session))
  end
  def test_external_link
    assert_kind_of(HtmlGrid::Link, @links.external_link(@model, 'key'))
  end
  def test_external_link__popup_links
    flexmock(@lnf, :enabled? => true)
    assert_kind_of(HtmlGrid::Link, @links.external_link(@model, 'key'))
  end
  def test_faq_link
    assert_kind_of(HtmlGrid::Link, @links.faq_link(@model, @session))
  end
  def test_generic_definition
    assert_kind_of(HtmlGrid::Link, @links.generic_definition(@model, @session))
  end
  def test_help_link
    assert_kind_of(HtmlGrid::Link, @links.help_link(@modle, @session))
  end
  def test_data_declaration
    assert_kind_of(HtmlGrid::Link, @links.data_declaration(@model, @session))
  end
  def test_legal_note
    assert_kind_of(HtmlGrid::Link, @links.legal_note(@model, @session))
  end
  def test_meddrugs_update
    assert_kind_of(ODDB::View::NavigationLink, @links.meddrugs_update(@model, @session))
  end
end
  end # View
end # ODDB
