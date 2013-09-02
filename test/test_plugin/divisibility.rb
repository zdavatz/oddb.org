#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDrugbankPlugin -- oddb.org -- 29.08.2012 -- yasaka@ywesee.com

require 'pathname'
require 'test/unit'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/divisibility'

module Kernel
  def self.capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval "$#{stream} = #{stream.upcase}"
    end
    result
  end
end
module ODDB
  class DivisibilityPlugin < Plugin
    attr_accessor :updated_sequences, :created_div, :updated_div
  end
end

module ODDB
  class TestDivisibilityPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app    = FlexMock.new 'app'
      @plugin = DivisibilityPlugin.new @app
      @div = flexmock('division')
      @div.should_receive(:pointer).and_return('div-pointer')
      @sequence = flexmock('sequence')
      @sequence.should_receive(:iksnr).and_return('00000')
      @sequence.should_receive(:seqnr).and_return('000')
    end
    def teardown
      #pass
    end
    def test_update_from_csv_with_invalid_path
      stdout = Kernel.capture(:stdout){ @plugin.update_from_csv 'bad_ext.pdf' }
      assert_equal(stdout.chomp, 'Error: No such CSV File bad_ext.pdf')
      assert_equal(@plugin.created_div, 0)
      assert_equal(@plugin.updated_div, 0)
      assert_equal(@plugin.updated_sequences, [])
      stdout = Kernel.capture(:stdout){ @plugin.update_from_csv '/dev/null/not_found.csv' }
      assert_equal(stdout.chomp, 'Error: No such CSV File /dev/null/not_found.csv')
      assert_equal(@plugin.created_div, 0)
      assert_equal(@plugin.updated_div, 0)
      assert_equal(@plugin.updated_sequences, [])
    end
    def test_update_from_csv_with_valid_path
      # TODO
      # Test here CSV parsing
      assert_equal(@plugin.created_div, 0)
      assert_equal(@plugin.updated_div, 0)
      assert_equal(@plugin.updated_sequences, [])
    end
    def test_report
      report = @plugin.report
      assert_equal 3, report.split("\n").length
      @plugin.updated_sequences = [@sequence]
      report = @plugin.report
      assert_equal 5, report.split("\n").length
    end
  end
end
