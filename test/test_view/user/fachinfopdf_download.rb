#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestFachinfoPDFDownload -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/export'
require 'htmlgrid/composite'
require 'view/user/fachinfopdf_download'

module ODDB
  module View
    module User

class StubFachinfoPDFDownloadInnerComposite < FachinfoPDFDownloadInnerComposite
  def link_with_filesize(arg)
    'link_with_filesize'
  end
end
class TestFachinfoPDFDownloadInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @view    = ODDB::View::User::StubFachinfoPDFDownloadInnerComposite.new(@model, @session)
  end
  def test_fachinfo_pdf_download
    assert_equal('link_with_filesize', @view.fachinfo_pdf_download(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
