#!/usr/bin/env ruby
# View::User::TestDownloadExport -- oddb.org -- 10.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/select'
require 'htmlgrid/labeltext'
require 'htmlgrid/template'
require 'view/resulttemplate'
require 'view/user/download_export'

class TestDownloadExportInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:attributes).and_return({})
      l.should_receive(:resource_global).and_return('http://ywesee.com')
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
    end
    @model = flexmock('model')
    @composite = ODDB::View::User::DownloadExportInnerComposite.new(@model, @session)
  end
  def test_compression_label
    assert_kind_of(HtmlGrid::LabelText, @composite.compression_label(@model, @session))
  end
end

class TestDownloadExportComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:attributes).and_return({})
      l.should_receive(:resource_global).and_return('http://ywesee.com')
      l.should_receive(:language)
      l.should_receive(:base_url)
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
    end
    @model = flexmock('model')
    @composite = ODDB::View::User::DownloadExportComposite.new(@model, @session)
  end
  def test_download_export_descr
    assert_kind_of(HtmlGrid::Link, @composite.download_export_descr(@model, @session))
  end
end
