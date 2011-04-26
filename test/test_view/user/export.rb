#!/usr/bin/env ruby
# ODDB::View::User::TestExport -- oddb.org -- 26.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/export'
require 'htmlgrid/link'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/select'
require 'view/resulttemplate'
require 'state/user/global'
require 'htmlgrid/inputradio'


module ODDB
  module State
    module User
      class DownloadExport < ODDB::State::User::Global
      end
    end
  end
end

module ODDB
  module View
    module User
      DOWNLOAD_UNCOMPRESSED = ['filename']
      class StubExport
        def initialize(model, session)
          @model       = model
          @session     = session
          @lookandfeel = session.lookandfeel
        end
        include Export
      end

class TestExport < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :format_price    => 'format_price',
                        :resource_global => 'resource_global'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => 'user_input'
                       )
    @model   = flexmock('model')
    @export  = ODDB::View::User::StubExport.new(@model, @session)
  end
  def test_uncompressed
    assert(@export.uncompressed?('filename'))
  end
  def test_file_paths
    export_dir = ODDB::View::User::Export::EXPORT_DIR
    expected = [File.expand_path('filename', export_dir)]
    assert_equal(expected, @export.file_paths('filename'))
  end
  def test_file_paths__compressed
    export_dir = ODDB::View::User::Export::EXPORT_DIR
    expected = [
      File.expand_path('test.dat.zip', export_dir),
      File.expand_path('test.dat.gz', export_dir),
      File.expand_path('test.dat.tar.gz', export_dir)
    ]
    assert_equal(expected, @export.file_paths('test.dat'))
  end
  def test_file_path
    export_dir = ODDB::View::User::Export::EXPORT_DIR
    expected = File.expand_path('filename', export_dir)
    assert_equal(expected, @export.file_path('filename'))
  end
  def test_display
    assert_equal(false, @export.display?('filename'))
  end
  def test_display__true
    flexmock(File, 
             :exists? => true,
             :size    => 1
            )
    assert_equal(true, @export.display?('filename'))
  end
  def test_datadesc
    flexmock(File, 
             :exists? => true,
             :size    => 1
            )
    assert_kind_of(HtmlGrid::Link, @export.datadesc('filename'))
  end
  def test_example
    assert_kind_of(HtmlGrid::Link, @export.example('filename'))
  end
  def test_export_link
    assert_kind_of(HtmlGrid::Link, @export.export_link('key', 'filename'))
  end
  def test_convert_filesize
    flexmock(File, 
             :exist?  => true,
             :size    => 1058576
            )
    expected = '(&nbsp;~&nbsp;1&nbsp;MB)'
    assert_equal(expected, @export.convert_filesize('filename'))
  end
  def test_filesize
    flexmock(File, 
             :exist?  => true,
             :exists? => true,
             :size    => 1058576
            )
    expected = '(&nbsp;~&nbsp;1&nbsp;MB)'
    assert_equal(expected, @export.filesize('filename'))
  end
  def test_checkbox_with_filesize
    flexmock(File, 
             :exist?  => true,
             :exists? => true,
             :size    => 1058576
            )
    assert_kind_of(HtmlGrid::InputCheckbox, @export.checkbox_with_filesize('filename')[0])
  end
  def test_once
    flexmock(File, 
             :exist?  => true,
             :exists? => true,
             :size    => 1058576
            )
    result = @export.once('filename')
    assert_equal(2, result.length)
    assert_equal('format_price', result[0])
    assert_kind_of(HtmlGrid::Input, result[1])
  end
  def test_once_or_year
    flexmock(@session, :user_input => {'filename' => '1'})
    flexmock(File, 
             :exist?  => true,
             :exists? => true,
             :size    => 1058576
            )
    result = @export.once_or_year('filename')
    assert_equal(7, result.length) 
    assert_nil(result[1])
    assert_nil(result[3])
    assert_nil(result[5])
    assert_equal('format_price', result[2])
    assert_equal('format_price', result[6])
    assert_kind_of(HtmlGrid::InputRadio, result[0])
    assert_kind_of(HtmlGrid::InputRadio, result[4])
  end
  def test_once_or_year__month_12
    flexmock(@session, :user_input => {'filename' => '12'})
    flexmock(File, 
             :exist?  => true,
             :exists? => true,
             :size    => 1058576
            )
    result = @export.once_or_year('filename')
    assert_equal(7, result.length) 
    assert_nil(result[1])
    assert_nil(result[3])
    assert_nil(result[5])
    assert_equal('format_price', result[2])
    assert_equal('format_price', result[6])
    assert_kind_of(HtmlGrid::InputRadio, result[0])
    assert_kind_of(HtmlGrid::InputRadio, result[4])
  end

end

    end # User
  end # View
end # ODDB
