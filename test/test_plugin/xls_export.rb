#!/usr/bin/env ruby
# ODDB::TestXlsExportPlubin -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path("..", File.dirname(__FILE__))
#$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'drb/drb'
require 'plugin/xls_export'

module ODDB
  class TestXlsExportPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def replace_constant(constant, temp)
      stderr_null do
        keep = eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end
    def setup
      @app    = flexmock('app')
      @plugin = ODDB::XlsExportPlugin.new(@app)
    end
    def test_export_competition
      company = flexmock('company', 
                         :name    => 'name',
                         :odba_id => 123,
                         :competition_email => 'competition_email'
                        )
      server = flexmock('server', :export_competition_xls => 'export_competition_xls')
      replace_constant('ODDB::XlsExportPlugin::EXPORT_SERVER', server) do 
        assert_equal('export_competition_xls', @plugin.export_competition(company))
      end
    end
    def test_export_generics
      server = flexmock('server', :export_generics_xls => 'export_generics_xls')
      replace_constant('ODDB::XlsExportPlugin::EXPORT_SERVER', server) do 
        assert_equal('export_generics_xls', @plugin.export_generics)
      end
    end
    def test_log_info
      @plugin.instance_eval do 
        @file_path = 'file_path'
        @nil_data  = ['nil_data']
      end
      recipients = ['xxx@ywesee.com']
      replace_constant('ODDB::XlsExportPlugin::RECIPIENTS', recipients) do 
        expected = {
          :files => {"file_path" => "application/vnd.ms-excel"}, 
          :report => "", 
          :recipients => ["xxx@ywesee.com"], 
          :change_flags => {},
          :report => "file_path\n\nThere is nil data in the patents.xls file. Most probably \"Bezeichnung\" is missing.\nnil_data"
        }
        assert_equal(expected, @plugin.log_info)
      end
    end
  end
  class XlsExportPlugin < Plugin
    @@today = Date.new(2011,2,3)
  end
  class TestXlsExportPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def test_export_patents
      patent = flexmock('patent', :expiry_date => Date.new(2011,2,4))
      registration = flexmock('registration', 
                              :patent  => patent,
                              :odba_id => 123
                             )
      flexmock(@app, :sorted_patented_registrations => [registration])
      server = flexmock('server', :export_patent_xls => 'export_patent_xls')
      replace_constant('ODDB::XlsExportPlugin::EXPORT_SERVER', server) do 
        assert_equal('export_patent_xls', @plugin.export_patents)
      end
    end
  end

end # ODDB
