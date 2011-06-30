#!/usr/bin/env ruby
# ODDB::View::User::TestSponsorLink -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/passthru'
require 'view/user/sponsorlink'
require 'util/logfile'


module ODDB
  module View
    module User

class TestSponsorLink < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    @model   = flexmock('model', :url => 'url')
    @link    = ODDB::View::User::SponsorLink.new(@model, @session)
  end
  def test_sponsorlink
    assert_equal('http://url', @link.sponsorlink)
  end
  def test_sponsorlink__https
    flexmock(@model, :url => 'https://url')
    assert_equal('https://url', @link.sponsorlink)
  end
  def test_http_headers
    assert_equal({"Location" => "http://url"}, @link.http_headers)
  end
  def test_to_html
    flexmock(LogFile, :append => 'append')
    flexmock(@session, 
             :remote_addr => 'remote_addr',
             :flavor      => 'flavor'
            )
    assert_equal('', @link.to_html('context'))
  end
end

    end # User
  end # View
end # ODDB
