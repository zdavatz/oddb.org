#!/usr/bin/env ruby
# TestExporter -- oddb -- 07.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/exporter'
require 'util/log'
require 'date'

def sleep(*args)
end
def run_on_weekday(*args)
  yield
end

module ODDB
  class StubDRbObject
    def clear
    end
  end
  class Exporter
    remove_const :EXPORT_SERVER
    EXPORT_SERVER = StubDRbObject.new
    @@today = Date.new(2011,2,3)
  end
  class TestExporter < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      app = flexmock('app') 
      @exporter = ODDB::Exporter.new(app)
      @log = flexmock('log') do |log|
        log.should_receive(:report)
        log.should_receive(:notify)
        log.should_receive(:report=)
      end
      @export = flexmock('exporter') do |exp|
          exp.should_receive(:export_fachinfos)
      end
      flexstub(OdbaExporter::OddbDatExport) do |oddb|
        oddb.should_receive(:new).and_return(@export)
      end

    end
    def test_export_oddbdat
      flexstub(Log) do |logclass|
        # white box test: Log.new is never called
        # if dose_missing_list is not empty or an error raises,
        # Log.new will be called
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexstub(@export) do |exp|
          exp.should_receive(:export).and_return([]) # this is the key point
      end

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__dose_missing
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of dose data missing
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(@export) do |exp|
          exp.should_receive(:export).and_return(['dose_missing']) # this is the key point
      end

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__error
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of StarndardError
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(@export) do |exp|
          exp.should_receive(:export).and_return([]) # this is the key point
      end
      flexstub(Exporter::EXPORT_SERVER).should_receive(:clear).and_raise(StandardError)

      assert_equal(nil, @exporter.export_oddbdat)
    end
  end
end

