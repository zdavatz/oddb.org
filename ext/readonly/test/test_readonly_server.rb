#!/usr/bin/env ruby
# ODDB::TestReadonlyServer -- oddb.org/ext -- 16.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'readonly_server'
require 'model/atcclass'
require 'model/company'
require 'model/package'
require 'util/exporter'

module ODDB
  Currency = 'test'
  class TestReadonlyServer < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @serv = ReadonlyServer.new 
    end
    def test_remote_comparables
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:atc_code)
        seq.should_receive(:comparable?).and_return(true)
      end
      package = flexmock('package') do |pac|
        pac.should_receive(:sequence).and_return(sequence)
        pac.should_receive(:comparable?).and_return(true)
      end
      flexstub(sequence) do |seq|
        seq.should_receive(:packages).and_return({1=>package})
      end
      flexstub(ODDB::Remote::Package) do |pac|
        pac.should_receive(:new).and_return(package)
      end
      atc = flexmock('atcs') do |at|
        at.should_receive(:sequences).and_return([sequence])
      end
      atcs = [atc]
      flexstub(ODBA) do |odba|
        odba.should_receive(:cache).and_return(flexmock('cache') do |cache|
          cache.should_receive(:retrieve_from_index).and_return(atcs)
        end)
      end
      assert_equal([package], @serv.remote_comparables(package))
    end
    def test_remote_each_atc_class
      flexstub(ODDB::AtcClass) do |atc|
        atc.should_receive(:odba_extent).and_yield('atc')
      end
      @serv.remote_each_atc_class do |atc|
        assert_equal('atc', atc)
      end
    end
    def test_remote_each_company
      flexstub(ODDB::Company) do |comp|
        comp.should_receive(:odba_extent).and_return(['company'])
      end
      return_value = @serv.remote_each_company do |company|
        assert_equal('company', company)
      end
      assert_equal(nil, return_value)
    end
    def test_remote_each_package
      package = flexmock('package') do |pac|
        pac.should_receive(:public?).and_return(true)
        pac.should_receive(:narcotic?).and_return(false)
      end
      flexstub(ODDB::Package) do |pac|
        pac.should_receive(:odba_extent).and_return([package])
      end
      flexstub(ODBA::DRbWrapper) do |drb|
        drb.should_receive(:new).and_return(package)
      end
      return_value = @serv.remote_each_package do |pac|
        assert_equal(package, pac)
      end
      assert_equal(nil, return_value)
    end
    def test_remote_export
      flexstub(ODDB::Exporter) do |klass|
        klass.should_receive(:new).and_return(flexmock('exp') do |exp|
          exp.should_receive(:export_helper).once.with('name', Proc).and_yield('path')
        end)
      end
      @serv.remote_export('name') do |path|
        assert_equal('path', path)
      end
    end
    def test_remote_packages
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:public_packages).and_return('package')
      end
      flexstub(ODBA) do |odba|
        odba.should_receive(:cache).and_return(flexmock('cache') do |cache|
          cache.should_receive(:retrieve_from_index).once\
            .with('sequence_index_exact', 'query').and_return([sequence])
        end)
      end
      assert_equal(['package'], @serv.remote_packages('query'))
    end
  end
end
