#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'stub/odba'
require 'fileutils'
require 'flexmock'
require 'plugin/medical_products'
require 'model/text'
require 'model/atcclass'
require 'model/registration'

module ODDB
	class FachinfoDocument
		def odba_id
			1
		end
	end
  module SequenceObserver
    def initialize
    end
    def select_one(param)
    end
  end
    class StubLog
      include ODDB::Persistence
      attr_accessor :report, :pointers, :recipients, :hash
      def notify(arg=nil)
      end
    end
    class StubRegistration
      attr_accessor :company_name
      attr_accessor :generic_type
      attr_accessor :substance_names
      attr_accessor :packages
      attr_accessor :sequences
      attr_accessor :pointer
      attr_accessor :odba_store
      attr_accessor :name_base
      attr_accessor :sequence
      attr_accessor :export_flag
      def initialize(name)
        @name_base = name
        @packages = []
        @sequences = []
        @export_flag = true
        @pointer = FlexMock.new(Persistence::Pointer)
        @pointer.should_receive(:descriptions).and_return(@descriptions)
        @pointer.should_receive(:pointer).and_return(@pointer)
        @pointer.should_receive(:creator).and_return([])
        @pointer.should_receive(:+).and_return(@pointer)
      end
      def sequence(seqNr)
        @part_mock = FlexMock.new(ODDB::Part)
        @part_mock.should_receive(:size=)
        @part_mock.should_receive(:size).and_return('size of part')
        @part_mock.should_receive(:pointer).and_return(@pointer)
        @part_mock.should_receive(:odba_store)
        @package_mock = FlexMock.new(ODDB::Package)
        @package_mock.should_receive(:create_part).and_return(@part_mock)
        @package_mock.should_receive(:part).and_return(@part_mock)
        @package_mock.should_receive(:parts).and_return([@part_mock])
        @package_mock.should_receive(:pointer).and_return(@pointer)
        @package_mock.should_receive(:fix_pointers)
        @package_mock.should_receive(:odba_store)
        @package_mock.should_receive(:oid).and_return('1')
        @sequence = FlexMock.new(ODDB::Sequence)
        @sequence.should_receive(:create_package).and_return(@package_mock)
        @sequence.should_receive(:package).and_return(@package_mock)
        @sequence.should_receive(:packages).and_return([@package_mock])
        @sequence.should_receive(:pointer).and_return(Persistence::Pointer.new([:sequence, '32917', '00']))
        @sequence.should_receive(:fix_pointers)
        @sequence
      end
      def create_sequence(seqNr)
        @sequence = FlexMock.new(ODDB::Sequence)
        @sequence.should_receive(:create_package).and_return(@package)
        @sequence.should_receive(:package).and_return(@package)
        @sequence.should_receive(:packages).and_return([@package])
        @sequence.should_receive(:pointer).and_return(Persistence::Pointer.new([:sequence, '32917', '00']))
        @sequence.should_receive(:fix_pointers)
        @sequence
      end
      def odba_store
      end
      def fachinfo
        @fachinfo_mock = FlexMock.new(ODDB::Fachinfo)
        @fachinfo_mock.should_receive(:indication=)
        @fachinfo_mock.should_receive(:pointer).and_return(@pointer)
        @fachinfo_mock.should_receive(:descriptions).and_return(@descriptions_mock)
        @fachinfo_mock.should_receive(:pointer).and_return(@pointer)
        @fachinfo_mock
      end
    end
    class StubApp
      attr_writer :log_group
      attr_reader :pointer, :values, :model
      attr_accessor :last_date, :epha_interactions, :registrations
      def initialize
        @model = StubLog.new
        @epha_interactions = []
        @registrations = []
        @company_mock = FlexMock.new(ODDB::Company)
        @company_mock.should_receive(:pointer).and_return(@pointer)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock.should_receive(:odba_store)
        @descriptions_mock = FlexMock.new('descriptions')
        product_mock = FlexMock.new(@registrations)
        product_mock.should_receive(:odba_store)
        @pointer_mock = FlexMock.new(Persistence::Pointer)
        @pointer_mock.should_receive(:descriptions).and_return(@descriptions_mock)
        @pointer_mock.should_receive(:pointer).and_return(@pointer_mock)
        @pointer_mock.should_receive(:notify).and_return([])
        @pointer_mock.should_receive(:+).and_return(@pointer_mock)
      end
      def create_registration(name)
        @registration_stub = StubRegistration.new(name)
        @registrations << @registration_stub
        puts "StubApp create_registration #{name} now #{@registrations.size} @registrations"
        @registration_stub
      end
      def company_by_name(name, matchValue)
        @registration_stub
      end
      def registration(number)
        @registrations.first
      end
      def sequence(number)
        @sequence_mock
      end
      def create_fachinfo
        @fachinfo_mock
      end
      def odba_store
      end
      def odba_isolated_store
      end
      def create_epha_interaction(atc_code_self, atc_code_other)
        epha_interaction = ODDB::EphaInteraction.new
        mock = FlexMock.new(epha_interaction)
        @epha_interactions ||= []
        @epha_interactions << mock
        mock.should_receive(:odba_store)
        epha_interaction
      end
      def delete_all_epha_interactions
      end
      def update(pointer, values, reason = nil)
        @pointer = pointer
        @values = values
        return @company_mock if reason and reason.to_s.match('company')
        if reason and reason.to_s.match('registration')
          if @registrations.size == 0
            stub = StubRegistration.new('dummy')
            @registrations << stub
          else stub = @registrations.first
          end
          return stub
        end
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

  class TestMedicalProductPlugin <MiniTest::Unit::TestCase
    unless defined?(@@datadir)
      @@datadir = File.expand_path '../../ext/fiparse/test/data/docx/', File.dirname(__FILE__)
      @@vardir = File.expand_path '../var', File.dirname(__FILE__)
    end
    include FlexMock::TestCase
    
    def setup
      assert(File.directory?(@@datadir), "Directory #{@@datadir} must exist")
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
      @opts = {
        :lang  => 'de',
        :files => [ File.join(@@datadir, 'Sinovial_DE.docx') ],
      }
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
      @app = StubApp.new
    end # Fuer Problem mit fachinfo italic
    
    def teardown
      FileUtils.rm_rf @@vardir
      super # to clean up FlexMock
    end
    
    def test_update_medical_product_with_absolute_path
      fileName = File.join(@@datadir, 'Sinovial_DE.docx')
      assert(File.exists?(fileName), "File #{fileName} must exist")
      options = {:files => [ fileName ],  :lang => 'de' }
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
    end
    def test_update_medical_product_with_lang_and_relative
      fileName = 'Sinovial_DE.docx'
      options = {:files => [ fileName ],  :lang => 'de' }
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
    end
    def test_update_medical_product_with_relative_wildcard
      options = {:files => [ '*.docx']}
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
    end
    def test_update_medical_product_french
      options = {:files => [ '*.docx'], :lang => :fr}
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_FR.docx')
    end
  end
end 
