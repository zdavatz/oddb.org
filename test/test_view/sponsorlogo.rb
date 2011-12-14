#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestSponsorLogo -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/sponsorlogo'
require 'htmlgrid/span'


module ODDB
  module View

class TestCompanyLogo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup => 'lookup',
                          :resource_global => 'resource_global'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :logo_filename => 'logo_filename',
                          :name => 'name'
                         )
    @component = ODDB::View::CompanyLogo.new(@model, @session)
  end
  def test_init
    assert_equal('name', @component.init)
  end
  def test_to_html
    context = flexmock('context', :img => 'img')
    assert_equal('img', @component.to_html(context))
  end
end

class TestSponsorLogo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup   => 'lookup',
                          :language => 'language',
                          :format_date     => 'format_date',
                          :resource_global => 'resource_global.swf'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :name => 'name',
                          :logo_filename => 'logo_filename',
                          :sponsor_until => 'sponsor_until'
                         )
    @component = ODDB::View::SponsorLogo.new(@model, @session)
  end
  def test_init
    assert_equal('sponsor  right', @component.init)
  end
  def test_logo
    flexmock(@lnf, :resource_global => 'resource_global')
    context = flexmock('context', :img => 'img')
    @component.init
    assert_equal('img', @component.logo(context))
  end
  def test_logo__swf
    expected = "<object codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\">\n<param name=\"movie\" value=\"resource_global.swf\"/>\n<param name=\"play\" value=\"true\"/>\n<param name=\"quality\" value=\"best\"/>\n<embed src=\"resource_global.swf\" play=\"true\" quality=\"best\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\"/>\n</object>\n"
    assert_equal(expected, @component.logo('context'))
  end
  def test_to_html
    flexmock(@lnf, :_event_url => '_event_url')
    context = flexmock('context', :a => 'a')
    assert_equal('a', @component.to_html(context))
  end

end

  end # View
end # ODDB
