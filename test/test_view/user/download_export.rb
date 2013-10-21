#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestDownloadExport -- oddb.org -- 28.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/select'
require 'htmlgrid/labeltext'
require 'htmlgrid/template'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputradio'
require 'view/resulttemplate'
require 'view/user/download_export'
require 'state/user/global'
require 'state/user/download_export'


class TestDownloadExportInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url).and_return('_event_url')
      l.should_receive(:attributes).and_return({})
      l.should_receive(:resource_global).and_return('http://ywesee.com')
      l.should_receive(:format_price).and_return('format_price')
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:user_input).and_return('user_input')
    end
    @model = flexmock('model')
    @composite = ODDB::View::User::DownloadExportInnerComposite.new(@model, @session)
  end
  def test_compression_label
    assert_kind_of(HtmlGrid::LabelText, @composite.compression_label(@model, @session))
  end
end

class TestDownloadExportComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel') do |l|
      l.should_receive(:lookup).and_return('lookup')
      l.should_receive(:_event_url).and_return('_event_url')
      l.should_receive(:attributes).and_return({})
      l.should_receive(:resource_global).and_return('http://ywesee.com')
      l.should_receive(:language)
      l.should_receive(:base_url)
      l.should_receive(:format_price).and_return('format_price')
    end
    @session = flexmock('session') do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:user_input).and_return('user_input')
    end
    @model = flexmock('model')
    @composite = ODDB::View::User::DownloadExportComposite.new(@model, @session)
  end
  def test_download_export_descr
    assert_kind_of(HtmlGrid::Link, @composite.download_export_descr(@model, @session))
  end
end
