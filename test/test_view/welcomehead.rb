#!/usr/bin/env ruby
# ODDB::View::TestWelcomeHead -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/welcomehead'

module ODDB
  module View


class TestWelcomeHead < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :enabled?   => nil,
                          :attributes => {},
                          :resource   => 'resource'
                         )
    user       = flexmock('user', :valid? => nil)
    sponsor    = flexmock('sponsor', :valid? => nil)
    @session   = flexmock('session', 
                          :user => user,
                          :lookandfeel => @lnf,
                          :sponsor     => sponsor
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::WelcomeHead.new(@model, @session)
  end
  def test_banner__epatents
    flexmock(@lnf, :enabled? => true)
    expected = "<A HREF=\"http://petition.eurolinux.org\"><img src=\"http://aful.org/images/patent_banner.gif\" alt=\"Petition against e-patents\"></A><BR>"
    assert_equal(expected, @composite.banner(@model, @session))
  end
  def test_bannr__banner
    flexmock(@lnf) do |lnf|
      lnf.should_receive(:enabled?).with(:epatents).once.and_return(false)
      lnf.should_receive(:enabled?).with(:banner).once.and_return(true)
      lnf.should_receive(:_event_url)
    end
    assert_kind_of(HtmlGrid::Link, @composite.banner(@model, @session))
  end
  def test_banner__nil
    assert_nil(@composite.banner(@model, @session))
  end
  def test_home_welcome
    expected = ["lookup", "<br>", "lookup"]
    assert_equal(expected, @composite.home_welcome(@model, @session))
  end
  def test_home_welcome__screencast
    flexmock(@lnf, :enabled? => true)
    expected = ["lookup", "<br>", "lookup"]
    assert_kind_of(HtmlGrid::Link, @composite.home_welcome(@model, @session)[0])
  end

end

  end # View
end # ODDB

