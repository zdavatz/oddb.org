#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDrugbankPlugin -- oddb.org -- 29.08.2012 -- yasaka@ywesee.com

require 'pathname'

require 'minitest/autorun'
require 'flexmock/minitest'
root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')
$: << File.expand_path('..', File.dirname(__FILE__))
require 'stub/odba'
require 'stub/oddbapp'
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
  class TestDivisibilityPlugin <Minitest::Test
    def setup
      @app    = flexmock('app', ODDB::App.new)
      @plugin = DivisibilityPlugin.new @app
    end
    def teardown
      super # to clean up FlexMock
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
      reg_15678 =  @app.create_registration('15678')
      seq = reg_15678.create_sequence('01')
      seq.pointer = Persistence::Pointer.new([:registration, 15678, :sequence, seq.seqnr])
      pack = seq.create_package('062')
      seq.fix_pointers
      @app.should_receive(:registration).once.with('15678').and_return(reg_15678)
      @app.should_receive(:registration).and_return(nil)
      def @app.update(pointer, values, origin=nil)
        @system.update(pointer, values, origin)
      end
      @plugin.update_from_csv File.expand_path('../data/csv/teilbarkeit_example.csv', File.dirname(__FILE__))
      assert_equal(1, @plugin.created_div)
      assert_equal(0, @plugin.updated_div)
      assert_equal(1, @plugin.updated_sequences.size)
      assert_equal('Ja (siehe Bemerkung)', @plugin.updated_sequences.first.division.crushable)
      assert_equal('Nein', @plugin.updated_sequences.first.division.dissolvable)
      assert_equal('Nein', @plugin.updated_sequences.first.division.divisable)
      assert_equal('Zerkleinerung hat einen Wirkungsverlust zur Folge. Vorschlag: Methergin Tropflösung (auf Rezept)',
                   @plugin.updated_sequences.first.division.notes)
    end
    def test_report
      @div = flexmock('division')
      @div.should_receive(:pointer).and_return('div-pointer')
      @sequence = flexmock('sequence')
      @sequence.should_receive(:iksnr).and_return('00000')
      @sequence.should_receive(:seqnr).and_return('000')
      report = @plugin.report
      assert_equal 3, report.split("\n").length
      @plugin.updated_sequences = [@sequence]
      report = @plugin.report
      assert_equal 5, report.split("\n").length
    end
  end
end
