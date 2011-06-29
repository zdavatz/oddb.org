#!/usr/bin/env ruby
# ODDB::View::User::TestYamlExport -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/yamlexport'


module ODDB
  module View
    module User

class StubYamlExportInnerComposite < ODDB::View::User::YamlExportInnerComposite
  def link_with_filesize(arg)
    'link_with_filesize'
  end
end
class TestYamlExportInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::User::StubYamlExportInnerComposite.new(@model, @session)
  end
  def test_yaml_export_gz
    assert_equal('link_with_filesize', @composite.yaml_export_gz(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
