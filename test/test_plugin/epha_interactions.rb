#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'stub/odba'
require 'fileutils'
require 'flexmock/minitest'
require 'plugin/epha_interactions'
require 'model/text'
require 'model/atcclass'
require 'model/fachinfo'
require 'model/commercial_form'
require 'model/registration'

module ODDB
  module SequenceObserver
    def initialize
    end
    def select_one(param)
    end
  end
  class PseudoFachinfoDocument
    def descriptions
      { :de => FlexMock.new('descriptions') }
    end
  end
    class StubLog
      include ODDB::Persistence
      attr_accessor :report, :pointers, :recipients, :hash
      def notify(arg=nil)
      end
    end
    class StubPackage
      attr_accessor :commercial_forms
      def initialize
        @commercial_mock = FlexMock.new(ODDB::CommercialForm)
        @commercial_forms = [@commercial_mock]
      end
    end
    class ODDB::Registration
     def initialize(iksnr)
        @pointer = FlexMock.new(Persistence::Pointer)
        @pointer.should_receive(:descriptions).and_return(@descriptions)
        @pointer.should_receive(:pointer).and_return(@pointer)
        @pointer.should_receive(:creator).and_return([])
        @pointer.should_receive(:+).and_return(@pointer)
      @iksnr = iksnr
      @sequences = {}
      end
    end
    class StubApp
      attr_writer :log_group
      attr_reader :pointer, :values, :model
      attr_accessor :last_date, :epha_interactions, :registrations
      def initialize
        @model = StubLog.new
        @epha_interactions = []
        @registrations = {}
        @company_mock = FlexMock.new(ODDB::Company)
        @company_mock.should_receive(:pointer).and_return(@pointer)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock.should_receive(:odba_store)
        product_mock = FlexMock.new(@registrations)
        product_mock.should_receive(:odba_store)
        @pointer_mock = FlexMock.new(Persistence::Pointer)
        @descriptions_mock = FlexMock.new('descriptions')
        @pointer_mock.should_receive(:descriptions).and_return(@descriptions_mock)
        @pointer_mock.should_receive(:pointer).and_return(@pointer_mock)
        @pointer_mock.should_receive(:notify).and_return([])
        @pointer_mock.should_receive(:+).and_return(@pointer_mock)
      end
      def atc_class(name)
        @atc_name = name
        @atc_class_mock = FlexMock.new(ODDB::AtcClass)
        @atc_class_mock.should_receive(:pointer).and_return(@pointer_mock)
        @atc_class_mock.should_receive(:pointer_descr).and_return(@atc_name)
        @atc_class_mock.should_receive(:code).and_return(@atc_name)
        return @atc_class_mock
      end
      def commercial_form_by_name(name)
        if name.match(/Fertigspritze/i)
          @commercial_mock = FlexMock.new(ODDB::CommercialForm)
          @commercial_mock.should_receive(:pointer).and_return(@pointer_mock)
          return @commercial_mock
        else
          return nil
        end
      end
      def create_registration(name)
        @registration_stub = ODDB::Registration.new(name)
        @registrations[name] = @registration_stub
        @registration_stub
      end
      def company_by_name(name, matchValue)
        @registration_stub
      end
      def registration(number)
        @registrations[number.to_s]
      end
      def sequence(number)
        @sequence_mock
      end
      def create_fachinfo
        @fachinfo
      end
      def odba_store
      end
      def odba_isolated_store
      end
      def update(pointer, values, reason = nil)
        @pointer = pointer
        @values = values
        if reason and reason.to_s.match('medical_product')
          return @commercial_mock
        end
        return @company_mock if reason and reason.to_s.match('company')
        if reason.to_s.match(/registration/)
          number = pointer.to_yus_privilege.match(/\d+/)[0]
          stub = Registration.new(number)
          @registrations[number] = stub
          return stub
        elsif reason and reason.to_s.eql?('text_info')
           return PseudoFachinfoDocument.new
        end
        return PseudoFachinfoDocument.new
        @pointer_mock
      end
      def log_group(key)
        @log_group
      end
      def create(pointer)
        @log_group
      end
      def recount
        'recount'
      end
    end

  class TestEphaInteractionPlugin <Minitest::Test

    def setup
      FileUtils.rm_rf(ODDB::WORK_DIR)
      @app = StubApp.new
      @@datadir = File.join(ODDB::TEST_DATA_DIR, 'csv')
      eval("ODDB::EphaInteractions::CSV_FILE = '#{File.join(ODDB::WORK_DIR, File.basename(ODDB::EphaInteractions::CSV_FILE))}'")
      assert(File.directory?(@@datadir), "Directory #{@@datadir} must exist")
      FileUtils.mkdir_p ODDB::WORK_DIR
      @sequence = flexmock('sequence',
                           :packages => ['packages'],
                           :pointer => 'pointer',
                           :creator => 'creator')
      seq_ptr = flexmock('seq_ptr',
                          :pointer => 'seq_ptr.pointer')
      @pointer = flexmock('pointer',
                          :pointer => seq_ptr,
                          :packages => ['packages'])
      @sequence = flexmock('sequence',
                           :creator => @sequence)
      seq_ptr.should_receive(:+).with([:sequence, 0]).and_return(@sequence)
      FileUtils.rm_f(ODDB::EphaInteractions::CSV_FILE, verbose: true)
      @fileName = File.join(ODDB::WORK_DIR, 'epha_interactions_de_utf8-example.csv')
      @latest = @fileName.sub('.csv', '-latest.csv')
      @plugin = flexmock('epha_plugin', ODDB::EphaInteractionPlugin.new(@app, {}))
      @mock_latest = flexmock('latest', Latest)
      @mock_latest.should_receive(:fetch_with_http).with(ODDB::EphaInteractions::CSV_ORIGIN_URL).and_return(
        File.open(File.join(@@datadir, File.basename(@fileName))).read)
    end

    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def test_update_epha_interactions_empty
      assert(@plugin.update(@fileName))
      report = @plugin.report
      files = Dir.glob("#{ODDB::WORK_DIR}/*csv")
      assert_equal(3, files.size)
      assert(report.match("EphaInteractionPlugin.update latest"))
      assert(report.match(/Added 1 interactions/))
    end
    def test_update_epha_interactions_update
      FileUtils.rm(@latest, :verbose => false) if File.exist?(@latest)
      @plugin.should_receive(:fetch_with_http).with(ODDB::EphaInteractions::CSV_ORIGIN_URL).and_return('old_content')
      assert(@plugin.update(@fileName))
      report = @plugin.report
      files = Dir.glob("#{ODDB::WORK_DIR}/*.csv")
      assert_equal(3, files.size)
      assert(report.match("EphaInteractionPlugin.update latest"))
      assert(report.match(/Added 1 interactions/))
    end
  end
end
