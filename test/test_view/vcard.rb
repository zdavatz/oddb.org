#!/usr/bin/env ruby
# ODDB::View::TestVCard -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/vcard'

module ODDB
  module View

class TestVCard < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    address = flexmock('addresses', 
                       :fon => 'fon',
                       :fax => 'fax',
                       :plz => 'plz',
                       :street => 'street',
                       :number => 'number',
                       :city   => 'city'
                      )
    @model     = flexmock('model', 
                          :addresses => [address],
                          :name => 'name'
                         )
    @component = ODDB::View::VCard.new(@model, @session)
  end
  def test_init
    assert_equal([:addresses], @component.init)
  end
  def test_addresses
    expected = [
      "TEL;WORK;VOICE:fon",
      "TEL;WORK;FAX:fax",
      "ADR;POSTAL;CHARSET=UTF-8:;;street number;city;;plz",
      "LABEL;POSTAL;CHARSET=UTF-8:;;street number city  plz"
    ]
    assert_equal(expected, @component.addresses)
  end
  def test_http_headers
    flexmock(@component, :get_filename => 'filename')
    expected = {"Content-Disposition" => "attachment; filename=filename", "Content-Type" => "text/x-vCard"}
    assert_equal(expected, @component.http_headers)
  end
  def test_email
    flexmock(@model, :email => 'email')
    expected = ["EMAIL;TYPE=internet:email"]
    assert_equal(expected, @component.email)
  end
  def test_to_html
    context = flexmock('context')
    expected = "BEGIN:vCard\nVERSION:3.0\nTEL;WORK;VOICE:fon\nTEL;WORK;FAX:fax\nADR;POSTAL;CHARSET=UTF-8:;;street number;city;;plz\nLABEL;POSTAL;CHARSET=UTF-8:;;street number city  plz\nEND:vCard"
    assert_equal(expected, @component.to_html(context))
  end
  def test_name
    expected = ["FN;CHARSET=UTF-8:name", "N;CHARSET=UTF-8:name"]
    assert_equal(expected, @component.name)
  end
  def test_title
    flexmock(@model, :title => 'title')
    expected = ["TITLE;CHARSET=UTF-8:title"]
    assert_equal(expected, @component.title)
  end
end

  end # View
end # ODDB

