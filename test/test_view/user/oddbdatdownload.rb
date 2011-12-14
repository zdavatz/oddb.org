#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestODDBDatDownload -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/oddbdatdownload'


module ODDB
  module View
    module User

class StubOddbDatDownloadInnerComposite < OddbDatDownloadInnerComposite
  def link_with_filesize(arg)
    'link_with_filesize'
  end
end
class TestOddbDatDownloadInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::User::StubOddbDatDownloadInnerComposite.new(@model, @session)
  end
  def test_oddbdat_download_tar_gz
    assert_equal('link_with_filesize', @composite.oddbdat_download_tar_gz(@model, @session))
  end
end

    end # User
  end # View
end # ODB

