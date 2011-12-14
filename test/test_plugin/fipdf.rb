#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFiPDFExporter -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/fipdf'


module ODDB
  class TestFiPDFExporter < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      fachinfo = flexmock('fachinfo')
      @app    = flexmock('app', :fachinfos => {'key' => fachinfo})
      @plugin = ODDB::FiPDFExporter.new(@app)
    end
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
    def test_run
      writer = flexmock('writer', :write_pdf => 'write_pdf')
      replace_constant('ODDB::FiPDFExporter::WRITER', writer) do
        assert_equal('write_pdf', @plugin.run)
      end
    end
  end
end # ODDB
